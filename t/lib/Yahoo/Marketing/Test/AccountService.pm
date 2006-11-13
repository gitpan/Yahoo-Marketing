package Yahoo::Marketing::Test::AccountService;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/ Yahoo::Marketing::Test::PostTest /;
use Test::More;
use Module::Build;

use Yahoo::Marketing::AccountService;
use Yahoo::Marketing::UserManagementService;
use Yahoo::Marketing::User;
use Yahoo::Marketing::Address;
use Yahoo::Marketing::BillingUser;
use Yahoo::Marketing::CreditCardInfo;

#use SOAP::Lite +trace => [qw/ debug method fault /];

my $section = 'sandbox';


sub test_add_money_and_get_account_balance : Test(4) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::AccountService->new->parse_config( section => $section );

    my $balance = $ysm_ws->getAccountBalance(
        accountID => $ysm_ws->account,
    );
    ok( $balance );
    like( $balance, qr/^\d+\.\d+$/, 'looks like a float number' );

    $ysm_ws->addMoney(
        accountID => $ysm_ws->account,
        amount    => '108.01',
    );

    my $new_balance = $ysm_ws->getAccountBalance(
        accountID => $ysm_ws->account,
    );
    ok( $new_balance );
    is( sprintf('%.2f', $new_balance), sprintf('%.2f', $balance + 108.01 ), 'amount is right' );
}

sub test_get_and_set_charge_amount : Test(3) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::AccountService->new->parse_config( section => $section );

    my $charge_amount = $ysm_ws->getChargeAmount( accountID => $ysm_ws->account );
    ok( defined( $charge_amount ) );
    $ysm_ws->setChargeAmount(
        accountID    => $ysm_ws->account,
        chargeAmount => '300',
    );
    $charge_amount = $ysm_ws->getChargeAmount( accountID => $ysm_ws->account );
    is( $charge_amount, 300 );

    # test again
    $ysm_ws->setChargeAmount(
        accountID    => $ysm_ws->account,
        chargeAmount => 101,
    );
    $charge_amount = $ysm_ws->getChargeAmount( accountID => $ysm_ws->account );
    is( $charge_amount, 101 );
}

sub test_get_and_set_active_credit_card : Test(2) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::AccountService->new->parse_config( section => $section );

    my $active_payment_method_id = $ysm_ws->getActiveCreditCard( accountID => $ysm_ws->account );
    ok( $active_payment_method_id );

    my $user_service = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );
    my @payment_methods = $user_service->getPaymentMethods;
    # must at least have one payment_method
    if ( scalar @payment_methods == 1 ) {
        my $billing_user = Yahoo::Marketing::BillingUser->new
            ->email( 'name@domain.ext' )
            ->firstName( 'Firstname' )
            ->lastName( 'Lastname' )
            ->phone( '818-000-0000' )
            ;
        my $address = Yahoo::Marketing::Address->new
            ->address1( '123 Main St.' )
            ->city( 'Springfield' )
            ->state( 'CA' )
            ->country( 'US' )
            ->postalCode( '93265' )
            ;
        my $credit_card = Yahoo::Marketing::CreditCardInfo->new
            ->cardNumber( '4024007171205718' )
            ->cardType( 'VISA' )
            ->expMonth( '8' )
            ->expYear( '2018' )
            ->securityCode( '505' )
            ;

        my $new_payment_method_id = $user_service->addCreditCard(
            billingUserInfo => $billing_user,
            billingAddress  => $address,
            cc              => $credit_card,
        );

        @payment_methods = $user_service->getPaymentMethods;
    }

    my $another_payment_method;
    foreach (@payment_methods) {
        next if $_->ID == $active_payment_method_id;
        $another_payment_method = $_;
    }

    $ysm_ws->setActiveCreditCard(
        accountID       => $ysm_ws->account,
        paymentMethodID => $another_payment_method->ID,
    );
    is( $ysm_ws->getActiveCreditCard( accountID => $ysm_ws->account ), $another_payment_method->ID, 'payment method id is right' );

}

sub test_set_get_and_delete_continent_block_list : Test(8) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::AccountService->new->parse_config( section => $section );

    $ysm_ws->deleteContinentBlockListFromAccount(
        accountID => $ysm_ws->account,
    );

    my @continents;
    eval {
        @continents = $ysm_ws->getContinentBlockListForAccount(
            accountID => $ysm_ws->account,
        );
    };
    ok( $@ =~ /does not exist/ );

    ok( $ysm_ws->setContinentBlockListForAccount(
        accountID  => $ysm_ws->account,
        continents => [ qw(Africa) ],
    ) );

    @continents = $ysm_ws->getContinentBlockListForAccount(
        accountID => $ysm_ws->account,
    );
    ok( @continents );
    is( $continents[0], 'Africa' );

    ok( $ysm_ws->setContinentBlockListForAccount(
        accountID  => $ysm_ws->account,
        continents => [ qw(Europe Asia Australia) ],
    ) );

    @continents = $ysm_ws->getContinentBlockListForAccount(
        accountID => $ysm_ws->account,
    );
    ok( @continents );
    ok( grep { $_ eq 'Europe' } @continents );
    ok( grep { $_ eq 'Asia' } @continents );
}

sub test_get_account : Test(3) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::AccountService->new->parse_config( section => $section );

    my $account = $ysm_ws->getAccount( accountID => $ysm_ws->account );

    ok( $account );
    is( $account->ID, $ysm_ws->account, 'accountID is right' );
    is( $account->marketID, 'US', 'marketID is right' );
}

sub test_get_accounts : Test(2) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::AccountService->new->parse_config( section => $section );

    my @accounts = $ysm_ws->getAccounts;

    ok( @accounts );
    my $found = 0;
    foreach my $account ( @accounts ) {
        $found = 1 if $account->ID eq $ysm_ws->account;
    }
    is( $found, 1, 'found default account' );
}

sub test_get_account_status : Test(2) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::AccountService->new->parse_config( section => $section );

    my $account_status = $ysm_ws->getAccountStatus( accountID => $ysm_ws->account );

    ok( $account_status );
    like( $account_status, qr/^Active|Inactive$/, 'account status seems right' );
}

sub test_update_account : Test(7) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::AccountService->new->parse_config( section => $section );

    my $account = $ysm_ws->getAccount( accountID => $ysm_ws->account );
    ok( $account );
    my $market_id = $account->marketID;
    my $name = $account->name;
    my $display_url = $account->displayURL;

    $ysm_ws->updateAccount(
        account => $account->marketID( 'US' )
                           ->name( 'update account test name' )
                           ->displayURL( 'http://searchmarketing.yahoo.com' ),
        updateAll => 'false',
    );
    $account = $ysm_ws->getAccount( accountID => $ysm_ws->account );
    is( $account->marketID, 'US', 'marketID is right' );
    is( $account->name, 'update account test name', 'name is right' );
    is( $account->displayURL, 'http://searchmarketing.yahoo.com', 'displayURL is right' );

    $ysm_ws->updateAccount(
        account => $account->marketID( $market_id )
                           ->name( $name )
                           ->displayURL( $display_url ),
        updateAll => 'false',
    );
    $account = $ysm_ws->getAccount( accountID => $ysm_ws->account );
    is( $account->marketID, $market_id, 'marketID is right' );
    is( $account->name, $name, 'name is right' );
    is( $account->displayURL, $display_url, 'displayURL is right' );
}

sub test_update_account_status : Test(3) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::AccountService->new->parse_config( section => $section );

    my $account_status = $ysm_ws->getAccountStatus( accountID => $ysm_ws->account );
    ok( $account_status );
    my $new_status = $account_status eq 'Active' ? 'Inactive' : 'Active';

    $ysm_ws->updateStatusForAccount(
        accountID     => $ysm_ws->account,
        accountStatus => $new_status,
    );
    is( $ysm_ws->getAccountStatus( accountID => $ysm_ws->account ), $new_status, 'new status is right' );
    $ysm_ws->updateStatusForAccount(
        accountID     => $ysm_ws->account,
        accountStatus => $account_status,
    );
    is( $ysm_ws->getAccountStatus( accountID => $ysm_ws->account ), $account_status, 'change back to old status' );
}

1;
