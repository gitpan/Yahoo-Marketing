package Yahoo::Marketing::CombinedAccountStatus;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::CombinedAccountStatus - an object to represent the status of the account as set by the user and the online status of the account as set by the system.

=cut

sub _user_setable_attributes {
    return ( qw/ 
                accountStatus
                onlineStatus
                onlineStatusAsOf
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

See L<http://ysm.techportal.searchmarketing.yahoo.com/docs/reference/dataObjects.asp> for documentation of the various data objects.


=head2 new

Creates a new instance

=cut

=head1 METHODS

=head2 get/set methods

=over 8

accountStatus
onlineStatus
onlineStatusAsOf

=back

=head2 get (read only) methods

=over 8


=back

=cut

