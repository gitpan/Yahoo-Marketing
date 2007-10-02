package Yahoo::Marketing::Service;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings; 

use base qw/ Class::Accessor::Chained Yahoo::Marketing /;

use Carp;
use YAML qw/DumpFile LoadFile Dump/;
use XML::XPath;
use SOAP::Lite on_action => sub { sprintf '' };
use Scalar::Util qw/ blessed /;
use Cache::FileCache;
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
                               fault
                               immortal
                          / );


sub new {
    my ( $class, %args ) = @_;

    # some defaults
    $args{ use_wsse_security_headers } = 1       unless exists $args{ use_wsse_security_headers };
    $args{ use_location_service }      = 1       unless exists $args{ use_location_service };
    $args{ cache_expire_time }         = '1 day' unless exists $args{ cache_expire_time };
    $args{ version }                   = 'V3'    unless exists $args{ version };

    $args{ uri } = 'http://marketing.ews.yahooapis.com/V3' 
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

    foreach my $config_setting ( qw/ username password master_account license endpoint uri version / ){
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
    and $locations->{ $self->version }->{ $self->endpoint }
    and $locations->{ $self->version }->{ $self->endpoint }->{ $self->master_account } ){
        return $locations->{ $self->version }->{ $self->endpoint }->{ $self->master_account };
    }

    my $som = $self->_soap( $self->endpoint
                           .'/'
                           .$self->version
                           .'/LocationService' 
                          )
                   ->getMasterAccountLocation( $self->_headers( no_account => 1 ) );

    if( $som->fault ){
        $self->fault( $self->_get_api_fault_from_som( $som ) );
        $self->_die_with_soap_fault( $som ) unless $self->immortal;
        warn "we could not determine the correct location endpoint, trying with default";
        return $self->endpoint.'/'.$self->version;
    }
    

    my $location = $som->valueof( '/Envelope/Body/getMasterAccountLocationResponse/out' );

    die "failed to get Master Account Location!" unless $location;

    $location .= '/'.$self->version;

    $locations->{ $self->version }->{ $self->endpoint }->{ $self->master_account } = $location ;

    $self->cache->set( 'locations', $locations, $self->cache_expire_time );

    return $location;
}

sub _get_api_fault_from_som {
    my ( $self, $som ) = @_;

    my @faults = ( defined $som->faultdetail 
                 ? map { Yahoo::Marketing::ApiFault->_new_from_hash( $_ ) }
                       ( ref $som->faultdetail->{ApiFault} eq 'ARRAY' 
                           ? @{ $som->faultdetail->{ApiFault} }
                           : ( $som->faultdetail->{ApiFault} )
                       )
                 : Yahoo::Marketing::ApiFault->_new_from_hash( { code => 'none', message => 'none', } )
                 )  
    ;
    warn "warning, found more than 1 fault!  This is likely a bug in the web service itself, please report it"
        if @faults > 1;

    return $faults[0];
}


sub _die_with_soap_fault {
    my ( $self, $som ) = @_;

    croak(<<ENDFAULT);
SOAP FAULT!

String:  @{[ $som->faultstring ]}

Code:    @{[ $self->fault->code ]}
Message: @{[ $self->fault->message ]}

ENDFAULT
}


# not using memoize yet
our %_soap;
sub _soap {
    my ( $self, $endpoint ) = @_;

    $endpoint ||= $self->_proxy_url;

    $_soap{ $endpoint } 
        ||= SOAP::Lite->proxy( $endpoint )
                         ->ns( $self->uri, 'ysm' )
                         ->default_ns( $self->uri )
    ;

    return $_soap{ $endpoint };
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

    $self->fault(undef);

    # can't pull @args in as a hash, because we need to preserve the order

    my @soap_args;
    while( my $key = shift @args ){
        my $value = shift @args;
        push @soap_args,  $self->_serialize_argument( $key => $value );
    }

    my $som = $self->_soap->$method( @soap_args, $self->_headers );

    if( $som->fault ){
        $self->fault( $self->_get_api_fault_from_som( $som ) );
        $self->_die_with_soap_fault( $som ) unless $self->immortal;
        return;  # only reach this if we didn't die above
    }

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
            my $element_type = $self->_response_array_type_map( $type ); 
            @values = ref( $result->{ out }->{ $element_type } ) eq 'ARRAY' 
                    ? map { $self->_deserialize( $_, $element_type ) } @{ $result->{ out }->{ $element_type } } 
                    : ( $self->_deserialize( $result->{ out }->{ $element_type }, $element_type ) )
            ;
        }else{
            @values = $self->_deserialize( $result->{ out }, $type );
        }

        die 'Unable to parse response!' unless @values;

        return wantarray
             ? @values
             : $values[0];

    }

    return 1;   # no output, but seemed succesful
}


sub _deserialize {
    my ( $self, $hash, $type ) = @_;

    my @return_values;


    my $obj;

    if( ref $hash eq 'ARRAY' ){
        return map { $self->_deserialize( $_, $type ) } @{ $hash };
    }elsif( $type =~ /ArrayOf(.*)/ ){
        my $element_type = $1;
        return [ map { $self->_deserialize( $_, $element_type ) } ( ref $hash eq 'ARRAY' ? @{ $hash } : values %$hash ) ];
    }elsif( $type !~ /^xsd:|(?<!CombinedAccount)Status$|[Ss]tring$|Int$|Continent$/ ){
        $type =~ s/^tns://;

        # pull it in
        my $class = 'Yahoo::Marketing::'.ucfirst( $type );
        eval "require $class";

        die "whoops, couldn't load $class: $@" if $@;

        $obj = $class->new;
    }elsif( not ref $hash eq 'HASH'){
        return $hash;
    }else{  # this should never be reached
        confess "how did we get here?  type = $type, hash = $hash\n";
    }

    foreach my $key ( keys %$hash ){
        if( not ref $hash->{ $key } ){
            $obj->$key( $hash->{ $key } );
        }elsif( ref $hash->{ $key } eq 'ARRAY' ){ # better have an array arguement mapping
                my $type = $self->_simple_types( $key );

                return [ map { $self->_deserialize( $_, $type ) } @{ $hash->{ $key } } ];
        }elsif( ref $hash->{ $key } eq 'HASH' ){
            my $type = $self->_simple_types( $key );

            # special case for array types returning as just a hash with a single element.  Annoying.
            if( $type =~ /^ArrayOf/ ){
                $type = $self->_response_array_type_map( $type );
                $obj->$key( [ $self->_deserialize( $hash->{ $key }->{ (keys %{ $hash->{ $key } })[0] }, $type ) ] );
                next;
            }
                
            $obj->$key( $self->_deserialize( $hash->{ $key }, $type ) ); 
        }else{
            warn "can't handle $key in response yet ( $hash->{ $key } )\n";
        }
    }

    push @return_values, $obj;

    return wantarray
            ? @return_values
            : $return_values[0]
    ;
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
    my ( $self, %args ) = @_;

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
             ( $self->_add_account_to_header and not $args{ no_account } )
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

sub clear_cache {
    my $self = shift;
    $self->cache->clear;
    delete $service_data->{ $self->_wsdl } 
        if $service_data and $self->_wsdl_components_are_defined;
    return $self;
}

sub purge_cache {
    my $self = shift;
    $self->cache->purge;
    delete $service_data->{ $self->_wsdl } 
        if $service_data and $self->_wsdl_components_are_defined;
    return $self;
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
        }elsif( $node->getAttribute('name') and ($node->getAttribute('name') =~ /Response(Type)?$/) ){
            $self->_parse_response_type( $node, $xpath );
        }else{
            $self->_parse_request_type( $node, $xpath );
        }
    }

    $self->cache->set( $self->_wsdl, $service_data->{ $self->_wsdl }, $self->cache_expire_time );
    return;
}

sub _parse_request_type {
    my ( $self, $node, $xpath ) = @_;
    my $type_name = $node->getAttribute( 'name' );

    return unless $type_name;

    my $def = $xpath->find( qq{/wsdl:definitions/wsdl:types/xsd:schema/xsd:element[\@name='$type_name']/xsd:complexType/xsd:sequence/xsd:element} );

    return unless $def;

    foreach my $def_node ( $def->get_nodelist ){

        my $name = $def_node->getAttribute( 'name' );
        my $type = $def_node->getAttribute( 'type' );

        $self->_parse_array_of_type( $xpath, $name, $type, 'request' ) if $type=~ /^tns:ArrayOf/;

        $service_data->{ $self->_wsdl }->{ type_map }->{ $name } = $type ;
    }

    return;
}

sub _parse_response_type {
    my ( $self, $node, $xpath ) = @_;
    my $type_name = $node->getAttribute( 'name' );
    $type_name =~ s/(^tns:)|(^xsd:)//;

    my $def = $xpath->find( qq{/wsdl:definitions/wsdl:types/xsd:schema/xsd:element[\@name='$type_name']/xsd:complexType/xsd:sequence/xsd:element[\@name='out']} );
    return unless $def;

    my $def_node = ($def->get_nodelist)[0];   # there's always just one

    ( my $name = $def_node->getAttribute( 'name' ) ) =~ s/^tns://;
    ( my $type = $def_node->getAttribute( 'type' ) ) =~ s/^tns://;

    $self->_parse_array_of_type( $xpath, $name, $type, 'response' ) if $type =~ /^ArrayOf/;
 
    $service_data->{ $self->_wsdl }->{ response_map }->{ $type_name } = { $name => $type };

    return;
}

sub _parse_array_of_type {
    my ( $self, $xpath, $name, $type, $request_or_response ) = @_;

    $type =~ s/^(tns:)//;

    my $def_node = ($xpath->find( qq{/wsdl:definitions/wsdl:types/xsd:schema/xsd:complexType[\@name='$type']/xsd:sequence/xsd:element} )->get_nodelist)[0];
    die "couldn't find definition for $type!\n" unless $def_node;
    ( my $child = $def_node->getAttribute('name') ) =~ s/^tns://;

    $service_data->{ $self->_wsdl }->{ array_argument_type_map }->{ request }->{ $name } 
        = { type => $type, child => $child }
        if not $request_or_response or $request_or_response eq 'request';

    $service_data->{ $self->_wsdl }->{ array_argument_type_map }->{ response }->{ $name } 
        = { type => $type, child => $child }
        if not $request_or_response or $request_or_response eq 'response';

    ( my $type_name = $def_node->getAttribute('name') ) =~ s/^tns://;
    $service_data->{ $self->_wsdl }->{ array_type_map }->{ request }->{ $type } 
        = $type_name
        if not $request_or_response or $request_or_response eq 'request';

    $service_data->{ $self->_wsdl }->{ array_type_map }->{ response }->{ $type } 
        = $type_name
        if not $request_or_response or $request_or_response eq 'response';

    return; 
}


sub _parse_complex_type {
    my ( $self, $node, $xpath ) = @_;
    my $element_name = $node->getAttribute( 'name' );
    my $type_name = $element_name;

    my $def = $xpath->find( qq{/wsdl:definitions/wsdl:types/xsd:schema/xsd:complexType[\@name='$type_name']/xsd:sequence/xsd:element} );
    die "unable to get definition for $type_name" unless $def;

    foreach my $complex_type_node ( $def->get_nodelist ) {
        my $name = $complex_type_node->getAttribute('name');
        ( my $type = $complex_type_node->getAttribute('type') ) =~ s/^tns://;

        if( $type=~ /^ArrayOf/ ){
            if( $element_name =~ /Request(Type)?$/ ){
                $self->_parse_array_of_type( $xpath, $name, $type, 'request' );
            }elsif( $element_name =~ /Response(Type)?$/ ){
                $self->_parse_array_of_type( $xpath, $name, $type, 'response' );
            }else{
                $self->_parse_array_of_type( $xpath, $name, $type );
            }
        }

        $service_data->{ $self->_wsdl }->{ type_map }->{ $name } = $type =~ /^xsd:/ ? $type : 'tns:'.$type
    }

    return;
}

sub _wsdl_components_are_defined {
    my $self = shift;

    return defined $self->endpoint
       and defined $self->version
       and defined $self->_service_name
    ;
}

sub _wsdl {
    my $self = shift;

    return $self->endpoint.'/'.$self->version.'/'.$self->_service_name.'?wsdl';
}

sub _response_map {
    my ( $self, $method ) = @_;

    return $service_data->{ $self->_wsdl }->{ response_map }->{ $method.'Response' };
}

sub _request_array_argument_type_map {
    my ( $self, $array_of_type ) = @_;

    return $service_data->{ $self->_wsdl }->{ array_argument_type_map }->{ request }->{ $array_of_type };
}

sub _response_array_argument_type_map {
    my ( $self, $array_of_type ) = @_;

    return $service_data->{ $self->_wsdl }->{ array_argument_type_map }->{ response }->{ $array_of_type };
}


sub _request_array_type_map {
    my ( $self, $array_of_type ) = @_;

    return $service_data->{ $self->_wsdl }->{ array_type_map }->{ request }->{ $array_of_type };
}

sub _response_array_type_map {
    my ( $self, $array_of_type ) = @_;

    return $service_data->{ $self->_wsdl }->{ array_type_map }->{ response }->{ $array_of_type };
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

        if( my $type_def = $self->_request_array_argument_type_map( $name ) ) {   # it's one of those multiple methods

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
                         ->value( $self->_escape_xml_baddies("$value") )  # force it stringy for now
        ;
    }

    # don't do anything special
    return SOAP::Data->name( $name )
                     ->value( $self->_escape_xml_baddies($value) );
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
AdGroupService, ForecastService, etc) to inherit from.  It should not be used directly.

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

Defaults to http://marketing.ews.yahooapis.com/V3

=head2 master_account

Get/set the master account to be used for requests

=head2 account

Get/set the account to be used for requests.  Not all requests require an account.
Any service that deals with Campaigns (or Ad Groups, Ads, or Keywords) requires account
to be set.

L<http://ysm.techportal.searchmarketing.yahoo.com/docs/gsg/requests.asp#header>

=head2 immortal

If set to a true value, Yahoo::Marketing service objects will not die when a SOAP fault
is encountered.  Instead, $service->fault will be set to the ApiFault returned in the 
SOAP response.
    
Defaults to false.

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
