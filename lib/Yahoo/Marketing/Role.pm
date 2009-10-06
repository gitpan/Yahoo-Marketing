package Yahoo::Marketing::Role;
# Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::Role - an object to represent a user role for an account, for example, AccountAdministrator or CampaignManager. Roles determine the capabilities that a user has, which in turn determine the operations a user can execute within the system. The association between a User, a Role, and an Account is an Authorization.


=cut

sub _user_setable_attributes {
    return ( qw/ 
              name
            /  );
}

sub _read_only_attributes {
    return ( qw/
           / );
}

__PACKAGE__->mk_accessors( __PACKAGE__->_user_setable_attributes, 
                           __PACKAGE__->_read_only_attributes
                         );


1;
=head1 SYNOPSIS

See L<http://searchmarketing.yahoo.com/developer/docs/V6/reference/dataObjects.php> for documentation of the various data objects.


=head2 new

Creates a new instance

=cut

=head1 METHODS

=head2 get/set methods

=over 8

=back

=head2 get (read only) methods

name

=over 8


=back

=cut

