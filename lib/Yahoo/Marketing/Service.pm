package Yahoo::Marketing::Service;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings; 

use base qw/ Class::Accessor::Chained Yahoo::Marketing /;

use Carp;
use Cache::FileCache;
use YAML qw/DumpFile LoadFile Dump/;
use SOAP::Lite on_action => sub { sprintf '' };
use XML::XPath;
use Scalar::Util qw/ blessed /;
use Yahoo::Marketing::ApiFault;

our $service_data;

__PACKAGE__->mk_accessors( qw/ username
                               password
                               license
                               master_account
                               account
                               on_behalf_of_username
                               on_behalf_of_password
                               endpoint
                               use_wsse_security_headers
                               use_location_service
                               last_command_group
                               remaining_quota
                               uri
                               version
                               cache
                               cache_expire_time
                          / );


sub new {
    my ( $class, %args ) = @_;

    # some defaults
    $args{ use_wsse_security_headers } = 1       unless exists $args{ use_wsse_security_headers };
    $args{ use_location_service }      = 1       unless exists $args{ use_location_service };
    $args{ cache_expire_time }         = '1 day' unless exists $args{ cache_expire_time };
    $args{ version }                   = 'V1'    unless exists $args{ version };

    $args{ uri } = 'http://marketing.ews.yahooapis.com/V1' 
        unless exists $args{ uri };

    my $self = bless \%args, $class;
    
    # setup our cache
    if( $self->cache ){
        croak "cache argument not a Cache::Cache object!" 
            unless ref $self->cache and $self->cache->isa( 'Cache::Cache' );
    }else{
        $self->cache( Cache::FileCache->new );
    }

    return $self;
}

sub wsdl_init {
    my $self = shift;

    $self->_parse_wsdl;
    return;
}

sub parse_config {
    my ( $self, %args ) = @_;

    $args{ path }    = 'yahoo-marketing.yml' unless defined $args{ path };
    $args{ section } = 'default'             unless defined $args{ section };

    my $config = LoadFile( $args{ path } );

    foreach my $config_setting ( qw/ username password master_account license endpoint uri / ){
        my $value = $config->{ $args{ 'section' } }->{ $config_setting };
        croak "no configuration value found for $config_setting in $args{ path }\n" 
            unless $value;
        $self->$config_setting( $value );
    }

    foreach my $config_setting ( qw/ default_account default_on_behalf_of_username default_on_behalf_of_password / ){
        my $value = $config->{ $args{ 'section' } }->{ $config_setting };
        my $setting_name = $config_setting;
        $setting_name =~ s/^default_//;
        # Maybe we should let the default overwrite ???
        $self->$setting_name( $value ) if defined $value and not defined $self->$setting_name;
    }

    return $self;
}

sub _service_name {
    my $self = shift;
    return (split /::/, ref $self)[-1] ;
}


sub _proxy_url {
    my $self = shift;
    return $self->_location.'/'.$self->_service_name;
}


sub _location {
    my $self = shift;

    unless( $self->use_location_service ){
        return $self->endpoint.'/'.$self->version;
    }

    my $locations = $self->cache->get( 'locations' );

    if( $locations 
    and $locations->{ $self->endpoint }
    and $locations->{ $self->endpoint }->{ $self->master_account } ){
        return $locations->{ $self->endpoint }->{ $self->master_account };
    }

    my $soap = SOAP::Lite->proxy( $self->endpoint
                                 .'/'
                                 .$self->version
                                 .'/LocationService' 
                           )
                         ->ns( $self->uri, 'ysm' )
                         ->default_ns( $self->uri )
               ; 

    my $som = $soap->getMasterAccountLocation( $self->_headers );

    $self->_die_with_soap_fault( $som ) if ($som->fault);
    

    my $location = $som->valueof( '/Envelope/Body/getMasterAccountLocationResponse/out' );

    die "failed to get Master Account Location!" unless $location;

    $location .= '/'.$self->version;

    $locations->{ $self->endpoint }->{ $self->master_account } = $location ;

    $self->cache->set( 'locations', $locations, $self->cache_expire_time );

    return $location;
}

sub _croak_message_from_som {
    my ( $self, $som ) = @_;

    my @api_faults = defined $som->faultdetail 
                     ? map { Yahoo::Marketing::ApiFault->_new_from_hash( $_ ) }
                           ( ref $som->faultdetail->{ApiFault} eq 'ARRAY' 
                               ? @{ $som->faultdetail->{ApiFault} }
                               : ( $som->faultdetail->{ApiFault} )
                           )
                     : Yahoo::Marketing::ApiFault->_new_from_hash( { code => 'none', message => 'none', } )
    ;  

    my $croak_message = <<ENDFAULT;
SOAP FAULT!

String:  @{[ $som->faultstring ]}
ENDFAULT

    foreach my $api_fault ( @api_faults ){
        $croak_message .= <<ENDDETAIL;

Code:    @{[ $api_fault->code ]}
Message: @{[ $api_fault->message ]}

ENDDETAIL
    }

    return $croak_message;
}

sub _die_with_soap_fault {
    my ( $self, $som ) = @_;

    croak( $self->_croak_message_from_som( $som ) );
}


sub _soap {
    my ( $self, $endpoint ) = shift;
    return SOAP::Lite->proxy( $endpoint or $self->_proxy_url )
                     ->ns( $self->uri, 'ysm' )
                     ->default_ns( $self->uri )
    ;
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $method = $AUTOLOAD;
    $method =~ s/(.+)\:\://g;
    my $package = $1;

    my $self = shift;

    return if $method eq 'DESTROY' ;

    return $self->_process_soap_call( $package, $method, @_ );        
}


sub _process_soap_call {
    my ( $self, $package, $method, @args ) = @_;

    $self->wsdl_init unless defined $service_data->{ $self->_wsdl };

    # can't pull @args in as a hash, because we need to preserve the order

    my @soap_args;
    while( my $key = shift @args ){
        my $value = shift @args;
        push @soap_args,  $self->_serialize_argument( $key => $value );
    }

    my $som = $self->_soap->$method( @soap_args, $self->_headers );

    $self->_die_with_soap_fault( $som ) if ($som->fault);

    $self->_set_quota_from_som( $som );
    return $self->_parse_response( $som, $method );
}

sub _set_quota_from_som {
    my ( $self, $som ) = @_;

    my $remaining_quota = $som->valueof( '/Envelope/Header/remainingQuota' );
    my $command_group   = $som->valueof( '/Envelope/Header/commandGroup' );

    $self->last_command_group( $command_group );
    $self->remaining_quota( $remaining_quota );
    return;
}

sub _parse_response {
    my ( $self, $som, $method ) = @_;

    if( my $result = $som->valueof( '/Envelope/Body/'.$method.'Response/' ) ){

        # catch empty string responses
        return if ( not defined $result->{ out } ) or ( defined $result->{ out } and $result->{ out } eq '' );

        my @return_values;

        my $type = $self->_response_map( $method )->{ out };

        my @values;
        if( $type =~ /ArrayOf/ ){
            my $map = $self->_array_type_map( $type ); 
            $type = $map->{ type };
            @values = ref( $result->{ out }->{ $map->{ name } } ) eq 'ARRAY' ? @{ $result->{ out }->{ $map->{ name } } } : ( $result->{ out }->{ $map->{ name } } );
        }else{
            @values = ( $result->{ out } );
        }

        die 'Unable to parse response!' unless @values;

        confess "oops, trying to deserialize non trivial response, but cannot determine object type!" unless $type;

        if( (($type !~ /^tns:(.*Status|Continent)$/) or ($type =~ /^tns:Combined.*Status$/))
            and $type =~ s/^tns:// 
            and scalar @values ){  # make an object

            # pull it in
            my $class = "Yahoo::Marketing::$type";
            eval "require $class";

            die "whoops, couldn't load $class: $@" if $@;

            my $obj = $class->new;
            
            foreach my $hash ( @values ){
                push @return_values, $obj->_new_from_hash( $hash );
            }
        }else{
            push @return_values, @values;
        }

        return wantarray
             ? @return_values
             : $return_values[0];

    }

    return 1;   # no output, but seemed succesful
}

sub _is_not_trivial {
    my ( $self, $response_values ) = @_;

    return ref $response_values->[0];  # only looking at the first one.  Hope they're consistient!
    # TODO: use List::Utils any/all to croak of they don't all match?
}

sub _is_special_case {
    my ( $self, $response_values ) = @_;

    if( ref $response_values->[0] && defined $response_values->[0]->{ string } ){
        return 1;
    }
    return;
}


sub _headers {
    my ( $self ) = @_;

    confess "must set username and password"
        unless defined $self->username and defined $self->password;

    return ( $self->_login_headers,
             SOAP::Header->name('license')
                         ->value( $self->license )
                         ->uri( $self->uri )
                         ->prefix('')
             ,
             SOAP::Header->name('masterAccountID')
                         ->type('string')
                         ->value( $self->master_account )
                         ->uri( $self->uri )
                         ->prefix('')
             ,
             $self->_add_account_to_header
               ? SOAP::Header->name('accountID')
                             ->type('string')
                             ->value( $self->account )
                             ->uri( $self->uri )
                             ->prefix('')
               : ()
             ,
             $self->on_behalf_of_username
               ? SOAP::Header->name('onBehalfOfUsername')
                             ->type('string')
                             ->value( $self->on_behalf_of_username )
                             ->uri( $self->uri )
                             ->prefix('')
               : ()
             ,
             $self->on_behalf_of_password
               ? SOAP::Header->name('onBehalfOfPassword')
                             ->type('string')
                             ->value( $self->on_behalf_of_password )
                             ->uri( $self->uri )
                             ->prefix('')
               : ()
             ,
    );
}

sub _add_account_to_header { return 0; }  # default to false

sub _login_headers {
    my ( $self ) = @_;
    return $self->use_wsse_security_headers
           ? ( SOAP::Header->name( 'Security' )
                           ->value(
                  \SOAP::Header->name( 'UsernameToken' )
                               ->value( [ SOAP::Header->name('Username')
                                                      ->value( $self->username )
                                                      ->prefix('wsse')
                                          ,
                                          SOAP::Header->name('Password')
                                                      ->value( $self->password )
                                                      ->prefix('wsse')
                                          ,
                                        ]
                               )
                               ->prefix( 'wsse' )
                           )
                           ->prefix( 'wsse' )
                           ->uri( 'http://schemas.xmlsoap.org/ws/2002/04/secext' )
               ,
             )
           : (
               SOAP::Header->name('username')
                           ->value( $self->username )
                           ->uri( $self->uri )
                           ->prefix('')
               ,
               SOAP::Header->name('password')
                           ->value( $self->password )
                           ->uri( $self->uri )
                           ->prefix('')
               ,
             );
}

sub _parse_wsdl {
    my ( $self, ) = @_;

    if( my $wsdl_data = $self->cache->get( $self->_wsdl ) ){
        $service_data->{ $self->_wsdl } = $wsdl_data;
        return;
    }

    my $xpath = XML::XPath->new( 
                    xml => SOAP::Schema->new(schema_url => $self->_wsdl )->access 
                );

    foreach my $node ( $xpath->find( q{/wsdl:definitions/wsdl:types/xsd:schema/* } )->get_nodelist ){
        my $name = $node->getName;
        if( $name eq 'xsd:complexType' ){
            $self->_parse_complex_type( $node, $xpath );
        }elsif( $node->getAttribute('name') =~ /Response$/ ){
            $self->_parse_response_type( $node, $xpath );
        }else{
            $self->_parse_request_type( $node, $xpath );
        }
    }

    $self->cache->set( $self->_wsdl, $service_data->{ $self->_wsdl }, $self->cache_expire_time );
    return;
}

sub clear_cache {
    my $self = shift;
    $self->cache->clear;
    delete $service_data->{ $self->_wsdl } if $service_data;
    return $self;
}

sub purge_cache {
    my $self = shift;
    $self->cache->purge;
    delete $service_data->{ $self->_wsdl } if $service_data;
    return $self;
}

sub _parse_request_type {
    my ( $self, $node, $xpath ) = @_;
    my $element_name = $node->getAttribute( 'name' );
    my $element_type = $element_name;
    my $type_name = $element_name;
    $type_name =~ s/(^tns:)|(^xsd:)//;

    my $def = $xpath->find( qq{/wsdl:definitions/wsdl:types/xsd:schema/xsd:element[\@name='$type_name']/xsd:complexType/xsd:sequence/xsd:element} );

    return unless $def;

    foreach my $def_node ( $def->get_nodelist ){

        my $name = $def_node->getAttribute( 'name' );
        my $type = $def_node->getAttribute( 'type' );

        $self->_parse_array_of_type( $xpath, $name, $type ) if $type=~ /^tns:ArrayOf/;
        $service_data->{ $self->_wsdl }->{ type_map }->{ $name } = $type ;
    }

    return;
}

sub _parse_array_of_type {
    my ( $self, $xpath, $name, $type ) = @_;

    my $type_name = $type; $type_name =~ s/^tns://;
    my $def_node = ($xpath->find( qq{/wsdl:definitions/wsdl:types/xsd:schema/xsd:complexType[\@name='$type_name']/xsd:sequence/xsd:element} )->get_nodelist)[0];
    die "couldn't find definition for $type_name!\n" unless $def_node;
   
    $service_data->{ $self->_wsdl }->{ array_argument_type_map }->{ $name } 
        = { type => $type, child => $def_node->getAttribute('name') };
    $service_data->{ $self->_wsdl }->{ array_type_map }->{ $type } 
        = { type => $def_node->getAttribute('type'), name => $def_node->getAttribute('name') };

    return; 
}

sub _parse_response_type {
    my ( $self, $node, $xpath ) = @_;
    my $element_name = $node->getAttribute( 'name' );
    my $element_type = $element_name;
    my $type_name = $element_name;
    $type_name =~ s/(^tns:)|(^xsd:)//;

    my $def = $xpath->find( qq{/wsdl:definitions/wsdl:types/xsd:schema/xsd:element[\@name='$type_name']/xsd:complexType/xsd:sequence/xsd:element[\@name='out']} );
    return unless $def;

    my $def_node = ($def->get_nodelist)[0];   # there's always just one

    my $name = $def_node->getAttribute( 'name' );
    my $type = $def_node->getAttribute( 'type' );

    $self->_parse_array_of_type( $xpath, $name, $type ) if $type=~ /^tns:ArrayOf/;
 
    $service_data->{ $self->_wsdl }->{ response_map }->{ $element_name } = { $name => $type };

    return;
}


sub _parse_complex_type {
    my ( $self, $node, $xpath ) = @_;
    my $element_name = $node->getAttribute( 'name' );
    my $element_type = $element_name;
    my $type_name = $element_name;
    $type_name =~ s/(^tns:)|(^xsd:)//;

    my $def = $xpath->find( qq{/wsdl:definitions/wsdl:types/xsd:schema/xsd:complexType[\@name='$type_name']/xsd:sequence/xsd:element} );
    die "unable to get definition for $type_name" unless $def;

    foreach my $complex_type_node ( $def->get_nodelist ) {
        my $name = $complex_type_node->getAttribute('name');
        my $type = $complex_type_node->getAttribute('type');

        $self->_parse_array_of_type( $xpath, $name, $type ) if $type=~ /^tns:ArrayOf/;

        $service_data->{ $self->_wsdl }->{ type_map }->{ $name } = $type ;
    }

    return;
}



sub _wsdl {
    my $self = shift;

    return $self->endpoint.'/'.$self->version.'/'.$self->_service_name.'?wsdl';
}

sub _response_map {
    my ( $self, $method ) = @_;

    return $service_data->{ $self->_wsdl }->{ response_map }->{ $method.'Response' };
}

sub _array_argument_type_map {
    my ( $self, $array_of_type ) = @_;

    return $service_data->{ $self->_wsdl }->{ array_argument_type_map }->{ $array_of_type };
}


sub _array_type_map {
    my ( $self, $array_of_type ) = @_;

    return $service_data->{ $self->_wsdl }->{ array_type_map }->{ $array_of_type };
}


sub _simple_types {
    my ( $self, $name ) = @_;

    return $service_data->{ $self->_wsdl }->{ type_map }->{ $name } 
        if exists $service_data->{ $self->_wsdl }->{ type_map }->{ $name };
    return;
}


sub _class_name {
    my $self = shift;
    my $name =  (split /::/, ref $self)[-1] ;

    confess "no name in _class_name!" unless $name;

    return $name;
}

sub _status_type {
    my $self = shift;
    my $type = $self->_class_name;
    $type =~ s/(Service$|$)/Status/;
    return 'tns:'.$type;
}

sub _escape_xml_baddies {
    my ( $self, $input ) = @_;
    return unless defined $input;
    # trouble with HTML::Entities::encode_entities is it will happily double encode things
    # SOAP::Lite::encode_data also appears to have this problem
    #return encode_entities( $input );
    $input =~ s/&(?!\w+;)/&amp;/g;
    $input =~ s/</&lt;/g;
    $input =~ s/\]\]>/\]\]&gt;/g;  # From SOAP::Lite's encode_data
    #$input =~ s/"/&quot;/g;   # no values in attributes
    return $input;
}

sub _serialize_argument {
    my ( $self, $name, $value, @additional_values ) = @_;

    # there are three major decision paths here:

    # if we get multiple values (as an array reference)
    #   recurse a bit - serialize each individually (see above) and the serialize the whole, then return
    #   *NOTE* that our test for this is getting the first value as an array reference, and that's it.  
    #        We'll ignore everything else!  

    # if we get multiple values (as an array)
    #   return an array of each serialized individually

    # if we get a just one non-array ref value, serialize it 
    #   using ->_serialize if it's blessed 
    #   using ->_simple_types if they apply
    #  or just plain old

    if( ref $value eq 'ARRAY' ){

        if( my $type_def = $self->_array_argument_type_map( $name ) ) {   # it's one of those multiple methods

            return SOAP::Data->type( $type_def->{ 'type' } )
                             ->name( $name )
                             ->value( \SOAP::Data->value( $self->_serialize_argument( $type_def->{ 'child' } => @{$value} ) ) );
        }

        croak "trying to serialize non plural looking $name with an array reference as a value.  Not sure how to deal with this - aborting.";
    }

    if( scalar @additional_values ){
        my @return;
        foreach my $element ( $value, @additional_values ){
            push @return, $self->_serialize_argument( $name, $element );
        }
        return @return;
    }

    if( blessed( $value ) and $value->UNIVERSAL::isa( 'Yahoo::Marketing::ComplexType' ) ){
        my $type = $self->_simple_types( $name );
        return SOAP::Data->name( $name )
                         ->type( $type )
                         ->value( $self->_serialize_complex_type( $value ) )
        ;
    }elsif( my $type = $self->_simple_types( $name ) ){
        return SOAP::Data->name( $name )
                         ->type( $type )
                         ->value( $self->_escape_xml_baddies($value) ) 
        ;
    }

    # don't do anything special
    return SOAP::Data->name( $name )
                     ->value( $self->_escape_xml_baddies( $value ) );
}


sub _serialize_complex_type {
    my ( $self, $complex_type ) = @_;

    return \SOAP::Data->value( map { $self->_serialize_argument( $_, $complex_type->$_ )
                                   } 
                                   grep { defined $complex_type->$_ } $complex_type->_user_setable_attributes
                             )
                      ->type( $complex_type->_type )
    ;
}



1; # End of Yahoo::Marketing::Service

=head1 NAME

Yahoo::Marketing::Service - a base class for Service modules

=head1 SYNOPSIS

This module is a base class for various Service modules (CampaignService, 
AdGroupService) to inherit from.  It should not be used directly.

There are some methods common to all Services that are documented below.

See also perldoc Yahoo::Marketing::AccountService
                              ...::AdGroupService
                              ...::AdService
                              ...::BasicReportService
                              ...::BidInformationService
                              ...::BudgetingService
                              ...::CampaignService
                              ...::ExcludedWordsService
                              ...::ForecastService
                              ...::KeywordResearchService
                              ...::KeywordService
                              ...::LocationService
                              ...::MasterAccountService
                              ...::UserManagementService

Please see the API docs at 

L<http://ysm.techportal.searchmarketing.yahoo.com/docs/gsg/index.asp#services>

for details about what methods are available from each of the Services.


=head1 EXPORT

No exported functions

=head1 METHODS

=cut

=head2 new

Creates a new instance.

=head2 username

Get/set the username to be used for requests

=head2 password

Get/set the password to be used for requests

=head2 license

Get/set the license to be used for requests

=head2 version

Get/set the version to be used for requests

=head2 uri

Get/set the URI to be used for requests.  

Defaults to http://marketing.ews.yahooapis.com/V1

=head2 master_account

Get/set the master account to be used for requests

=head2 account

Get/set the account to be used for requests.  Not all requests require an account.
Any service that deals with Campaigns (or Ad Groups, Ads, or Keywords) requires account
to be set.

L<http://ysm.techportal.searchmarketing.yahoo.com/docs/gsg/requests.asp#header>

=head2 on_behalf_of_username

Get/set the onBehalfOfUsername to be used for requests.  

L<http://ysm.techportal.searchmarketing.yahoo.com/docs/gsg/auth.asp#onbehalfof>

=head2 on_behalf_of_password

Get/set the onBehalfOfPassword to be used for requests.  

L<http://ysm.techportal.searchmarketing.yahoo.com/docs/gsg/auth.asp#onbehalfof>

=head2 use_wsse_security_headers

If set to a true value, requests will use the WSSE headers for authentication.  See L<http://schemas.xmlsoap.org/ws/2002/04/secext/>

Defaults to true.

=head2 use_location_service

If set to a true value, LocationService will be used to determine the correct endpoint URL based on the account being used.

Defaults to true.

=head2 cache

Allows the user to pass in a Cache::Cache object to be used for cacheing WSDL information and account locations.  

Defaults to using Cache::FileCache 

=head2 cache_expire_time

Set the amount of time WSDL information should be cached.  

Defaults to 1 day.

=head2 purge_cache

Purges all expired items from the cache.  See purge() documentation in perldoc Cache::Cache.

=head2 clear_cache

Clears all items from the cache.  See clear() documentation in perldoc Cache::Cache.

=head2 last_command_group

After a request, this will be set to the name of the last command group used.

=head2 remaining_quota

After a request, this will be set to the amount of quota associated with the last command group used.

=head2 wsdl_init

Accesses the appropriate wsdl and parses it to determine how to serialize / deserialize requests and responses.  Note that you must have set the endpoint.  

If you do not call it, calling any soap method on the service will force it to be called.

=head2 parse_config

Usage: 
    ->parse_config( path    => '/path/to/config.yml', 
                    section => 'some_section',         #  for example, 'sandbox'
                  );

Defaults:
    path    => 'yahoo-marketing.yml'    # in current working directory
    section => 'default'

Attempts to parse the given config file, or yahoo-marketing.ysm in the current
directory if no path is specified.  

parse_config() returns $self, so you can do things like this:

    my $service = Yahoo::Marketing::CampaignService->new->parse_config();

The default config section used is 'default'

Note that "default_account", "default_on_behalf_of_username", and "default_on_behalf_of_password" are not required.  If present, they will be used to set "account", "on_behalf_of_username", and "on_behalf_of_password" *if* those values have not already been set.  

See example config file in the EXAMPLES section of perldoc Yahoo::Marketing



=cut
