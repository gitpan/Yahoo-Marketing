package Yahoo::Marketing::ForecastResponse;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use Yahoo::Marketing::ForecastResponseData;
use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::ForecastResponse - an object to represent a Yahoo Marketing ForecastResponse.

=cut

sub _user_setable_attributes {
    return ( qw/ 
            /  );
}

sub _read_only_attributes {
    return ( qw/
                 forecastLandscape
                 forecastResponseDetail
           / );
}

__PACKAGE__->mk_accessors( __PACKAGE__->_user_setable_attributes, 
                           __PACKAGE__->_read_only_attributes
                         );


sub _new_from_hash {
    my ( $self, $hash ) = @_;

    my $obj = __PACKAGE__->new;
    foreach my $key ( keys %$hash ) {
        if ( $key eq 'forecastResponseDetail' ) {
            my $forecast_response_data = Yahoo::Marketing::ForecastResponseData->new->_new_from_hash( $hash->{$key} );
            $obj->$key( $forecast_response_data );
        }
        elsif ( $key eq 'forecastLandscape' ) {
            my @array;
            foreach my $item ( ref $hash->{ $key }{'ForecastResponseData'} eq 'ARRAY' 
                             ? @{ $hash->{ $key }{'ForecastResponseData'} } 
                             : ( $hash->{ $key }{'ForecastResponseData'} || () ) 
                             ) {
                my $forecast_response_data = Yahoo::Marketing::ForecastResponseData->new->_new_from_hash( $item );
                push @array, $forecast_response_data;
            }
            $obj->$key( @array ? \@array : undef );
        }
    }
    return $obj;
}

1;
=head1 SYNOPSIS

See http://ysm.techportal.searchmarketing.yahoo.com/docs/reference/dataObjects.asp for documentation of the various data objects.


=head2 new

Creates a new instance

=cut

=head1 METHODS

=head2 get/set methods

=over 8

    forecastLandscape
    forecastResponseDetail

=back

=head2 get (read only) methods

=over 8


=back

=cut

