package Yahoo::Marketing::Test::MasterAccount;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::MasterAccount;

sub test_can_create_master_account_and_set_all_fields : Test(8) {

    my $master_account = Yahoo::Marketing::MasterAccount->new
                                                        ->ID( 'id' )
                                                        ->currencyID( 'currency id' )
                                                        ->name( 'name' )
                                                        ->signupStatusText( 'signup status text' )
                                                        ->taggingON( 'tagging on' )
                                                        ->timezone( 'timezone' )
                                                        ->trackingON( 'tracking on' )
                   ;

    ok( $master_account );

    is( $master_account->ID, 'id', 'can get id' );
    is( $master_account->currencyID, 'currency id', 'can get currency id' );
    is( $master_account->name, 'name', 'can get name' );
    is( $master_account->signupStatusText, 'signup status text', 'can get signup status text' );
    is( $master_account->taggingON, 'tagging on', 'can get tagging on' );
    is( $master_account->timezone, 'timezone', 'can get timezone' );
    is( $master_account->trackingON, 'tracking on', 'can get tracking on' );

};



1;

