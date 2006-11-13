package Yahoo::Marketing::Test::MasterAccountService;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/ Yahoo::Marketing::Test::PostTest /;
use Test::More;

use Yahoo::Marketing::User;
use Yahoo::Marketing::Address;
use Yahoo::Marketing::Account;
use Yahoo::Marketing::BillingUser;
use Yahoo::Marketing::MasterAccount;
use Yahoo::Marketing::CreditCardInfo;
use Yahoo::Marketing::MasterAccountService;

#use SOAP::Lite +trace => [qw/ debug method fault /];

my $section = 'sandbox';


sub test_get_master_account : Test(7) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::MasterAccountService->new->parse_config( section => $section );

    my $master_account = $ysm_ws->getMasterAccount( masterAccountID => $ysm_ws->master_account );

    ok( $master_account );
    is( $master_account->ID, $ysm_ws->master_account, 'master account id is right' );
    ok( $master_account->currencyID );
    ok( $master_account->timezone );
    ok( $master_account->name );
    is( $master_account->signupStatusText, undef, 'signupStatusText is undef' );
    ok( $master_account->trackingON =~ /^(false|true)$/ );
}

sub test_get_master_account_status : Test(1) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::MasterAccountService->new->parse_config( section => $section );

    my $master_account_status = $ysm_ws->getMasterAccountStatus( masterAccountID => $ysm_ws->master_account );
    ok( $master_account_status =~ /^(Active|Inactive)$/, 'master account status is right' );
}

sub test_update_master_account : Test(6) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::MasterAccountService->new->parse_config( section => $section );

    my $master_account = $ysm_ws->getMasterAccount( masterAccountID => $ysm_ws->master_account );
    my $old_name = $master_account->name;
    my $old_tracking_on = $master_account->trackingON;

    $ysm_ws->updateMasterAccount(
        masterAccount => $master_account->name( "new name $$" )
                                        ->trackingON( $old_tracking_on eq 'false' ? 'true' : 'false' )
                                        ->timezone('America/Los_Angeles')
        ,
    );

    my $fetched_master_account = $ysm_ws->getMasterAccount( masterAccountID => $ysm_ws->master_account );

    ok( $fetched_master_account );
    is( $fetched_master_account->name, "new name $$", 'name is right' );
    is( $fetched_master_account->trackingON, $old_tracking_on eq 'false' ? 'true' : 'false', 'trackingON is right' );

    $ysm_ws->updateMasterAccount(
        masterAccount => $master_account->name( $old_name )
                                        ->trackingON( $old_tracking_on ),
    );

    $fetched_master_account = $ysm_ws->getMasterAccount( masterAccountID => $ysm_ws->master_account );

    ok( $fetched_master_account );
    is( $fetched_master_account->name, $old_name, 'name changed back' );
    is( $fetched_master_account->trackingON, $old_tracking_on, 'trackingON changed back' );

}


sub _make_username {
    my $time = time();
    return 'tu'.substr( $time, length($time) - 8, length( $time ) );
}


sub test_add_new_customer : Test(8) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::MasterAccountService->new->parse_config( section => $section );

    $ysm_ws->use_location_service( 0 );   # hack for integration env for now

    my $username = $self->_make_username;

    my $user = Yahoo::Marketing::User->new
                                     ->email( 'test@yahoo-inc.com' )
                                     ->firstName( 'test' )
                                     ->lastName( 'user' )
                                     ->locale( 'en_US' )
                                     ->mobilePhone( '111-111-1111' )
                                     ->timezone( 'America/Los_Angeles' )
                                     ->workPhone( '111-111-1111' )
    ;
    my $billing_user = Yahoo::Marketing::BillingUser->new
                                                    ->email( 'test@yahoo-inc.com' )
                                                    ->firstName( 'test' )
                                                    ->lastName( 'user' )
                                                    ->phone( '111-111-1111' )
    ;
    my $address = Yahoo::Marketing::Address->new
                                           ->address1('123 Sunshine Street')
                                           ->city('Sunnyvale')
                                           ->country('US')
                                           ->postalCode( '94089' )
                                           ->state( 'CA' )
    ;
    my $master_account = $ysm_ws->addNewCustomer( masterAccount      => Yahoo::Marketing::MasterAccount->new
                                                                                                       ->currencyID( 'USD' )   # we'll pay in silver!
                                                                                                       ->name( 'new master account test' )
                                                                                                       ->timezone( 'America/Los_Angeles' )
                                                                                                       ->trackingON( 'false' )
                                                  ,
                                                  account            => Yahoo::Marketing::Account->new
                                                                                                 ->marketID( 'US' )
                                                                                                 ->name( 'new account test' )
                                                                                                 ->vatCode( 1 )
                                                  ,
                                                  username           => $username,
                                                  userInfo           => $user,
                                                  address            => $address,
                                                  billingUserInfo    => $billing_user,
                                                  billingAddress     => $address,
                                                  cc                 => Yahoo::Marketing::CreditCardInfo->new
                                                                                                        ->cardNumber( '4111111111111111' )
                                                                                                        ->cardType( 'VISA' )
                                                                                                        ->expMonth( 2 )
                                                                                                        ->expYear( 2008 )
                                                                                                        ->securityCode( 123 )
                                                  ,
                                                  depositAmount      => 100,
                                                  promoCode          => '',   # can be null, must be present
                                  )
    ;

    ok( $master_account );
    like( $master_account->ID, qr/^\d+$/, 'ID is numeric' );
    is( $master_account->currencyID,  'USD', 'Currency ID is correct' );
    is( $master_account->taggingON, 'false', 'Tagging is not on' );
    is( $master_account->timezone,  'America/Los_Angeles', 'Timezone is correct' );
    is( $master_account->name,  'new master account test', 'Name is correct' );
    is( $master_account->signupStatusText, undef, 'signupStatusText is undef' );
    is( $master_account->trackingON,  'false', 'Tracking is not on' );
}


1;


__END__

    * addNewCustomer
    * getMasterAccount
    * getMasterAccountStatus
    * updateMasterAccount


