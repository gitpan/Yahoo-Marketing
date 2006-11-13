package Yahoo::Marketing::Test::PaymentMethodInfo;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::PaymentMethodInfo;

sub test_can_create_payment_method_info_and_set_all_fields : Test(4) {

    my $payment_method_info = Yahoo::Marketing::PaymentMethodInfo->new
                                                                 ->ID( 'id' )
                                                                 ->displayNumber( 'display number' )
                                                                 ->expirationDate( 'expiration date' )
                   ;

    ok( $payment_method_info );

    is( $payment_method_info->ID, 'id', 'can get id' );
    is( $payment_method_info->displayNumber, 'display number', 'can get display number' );
    is( $payment_method_info->expirationDate, 'expiration date', 'can get expiration date' );

};



1;

