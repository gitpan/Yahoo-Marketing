package Yahoo::Marketing::PaymentMethodInfo;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use Yahoo::Marketing::Address;
use Yahoo::Marketing::BillingUser;

use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::PaymentMethodInfo - an object to represent a Yahoo Marketing PaymentMethodInfo.

=cut

sub _user_setable_attributes {
    return ( qw/ 
                 ID
                 displayNumber
                 expirationDate
                 billingAddress
                 billingUser
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


=cut

=head1 METHODS

=head2 new

Creates a new instance

=head2 get/set methods

=over 8

    ID
    displayNumber
    expirationDate
    billingAddress
    billingUser

=back

=head2 get (read only) methods

=over 8


=back

=cut

