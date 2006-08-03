package Yahoo::Marketing::ResponseType;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use Carp;
use Yahoo::Marketing::Error;
use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::ResponseType - an object to represent a Yahoo Marketing CampaignResponse.
A base class for the various Response complexTypes, e.g. CampaignResponse, AdGroupResponse, AdResponse, etc.

=cut


sub _type_field {
    confess "_type_field must be defined in child class!";
}

sub _editorial_reasons_class {
    confess "_editorial_reasons_class must be defined in child class!";
}

sub _new_from_hash {
    my ( $self, $hash ) = @_;

    my $obj = $self->new;
    foreach my $key ( keys %$hash ) {
        if ( $key eq 'errors' ) {
            my @array;
            foreach my $item ( ref $hash->{ $key }{'Error'} eq 'ARRAY' ? @{ $hash->{ $key }{'Error'} } : ( $hash->{ $key }{'Error'} || () ) ) {
                my $error = Yahoo::Marketing::Error->new->_new_from_hash( $item );
                push @array, $error;
            }
            $obj->$key( @array ? \@array : undef );
        }elsif( $key eq 'operationSucceeded' )  {
            $obj->$key( $hash->{ $key } );
        }elsif ( $key =~ /editorialReasons$/i ) {
            my $editorial_reasons = $self->_editorial_reasons_class->_new_from_hash( $hash->{ $key } );
            $obj->$key( $editorial_reasons );
        }elsif( $key eq $self->_type_field ) {
            my $type = ucfirst $self->_type_field;

            # pull it in
            my $class = "Yahoo::Marketing::$type";
            eval "require $class";

            die "whoops, couldn't load $class: $@" if $@;

            my $field_obj = $class->new->_new_from_hash( $hash->{ $key } );
            
            $obj->$key( $field_obj );
        }else{
            confess "unknown field $key!";
        }
    }
    return $obj;
}


1;

=head1 SYNOPSIS

A base class for the various Response complexTypes, e.g. CampaignResponse, AdGroupResponse, AdResponse, etc.

=cut

