package Yahoo::Marketing::AmbiguousGeoMatch;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::AmbiguousGeoMatch - an object to represent a Yahoo Marketing AmbiguousGeoMatch.

=cut

sub _user_setable_attributes {
    return ( qw/ 
                 geoString
                 possibleMatches
            /  );
}

sub _read_only_attributes {
    return ( qw/
           / );
}

__PACKAGE__->mk_accessors( __PACKAGE__->_user_setable_attributes, 
                           __PACKAGE__->_read_only_attributes
                         );


sub _new_from_hash {
    my ( $self, $hash ) = @_;

    my $obj = __PACKAGE__->new;
    foreach my $key ( keys %$hash ) {
        if ( $key eq 'possibleMatches' ) {
            $obj->$key( $hash->{$key} ? $hash->{ $key }->{string} : undef );
        }
        else {
            $obj->$key( $hash->{$key} );
        }
    }
    return $obj;
}

1;
=head1 SYNOPSIS

See L<http://ysm.techportal.searchmarketing.yahoo.com/docs/reference/dataObjects.asp> for documentation of the various data objects.


=cut

=head1 METHODS

=head2 new

Creates a new instance

=head2 get/set methods

=over 8

    geoString
    possibleMatches

=back

=head2 get (read only) methods

=over 8


=back

=cut

