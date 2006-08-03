package Yahoo::Marketing::UserAuthorization;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use Yahoo::Marketing::Role;
use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::UserAuthorization - an object to represent an association between a User, a Role and an Account.

=cut

sub _user_setable_attributes {
    return ( qw/ 
               accountID
               role
               username
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
        if ( $key eq 'role' ) {
            my $role = Yahoo::Marketing::Role->new->_new_from_hash( $hash->{$key} );
            $obj->$key( $role );
        }
        else {
            $obj->$key( $hash->{ $key } );
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

accountID
role
username

=back

=head2 get (read only) methods

=over 8


=back

=cut

