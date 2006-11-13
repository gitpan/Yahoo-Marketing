package Yahoo::Marketing::Test::UserManagementService;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/ Yahoo::Marketing::Test::PostTest /;
use Test::More;

use Yahoo::Marketing::User;
use Yahoo::Marketing::Address;
use Yahoo::Marketing::Authorization;
use Yahoo::Marketing::Role;
use Yahoo::Marketing::BillingUser;
use Yahoo::Marketing::CreditCardInfo;
use Yahoo::Marketing::UserManagementService;

my $section = 'sandbox';


sub test_get_and_add_and_delete_authorization_for_user : Test(7) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    return 'no other active user we can test on this function.' unless $self->common_test_data( 'test_user' );

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );

    my $role = Yahoo::Marketing::Role->new->name( 'AccountManager' );

    ok( $ysm_ws->addAuthorizationForUser(
                 username      => $self->common_test_data( 'test_user' ),
                 authorization => Yahoo::Marketing::Authorization->new
                                                                 ->accountID( $ysm_ws->account )
                                                                 ->accountType( 'Account' )
                                                                 ->role( $role ),
             ), 'can add authorization' );

    my @auth = $ysm_ws->getAuthorizationsForUser( username => $self->common_test_data( 'test_user' ) );
    ok( @auth, 'can get authorization' );
    ok( ( grep { $_->role->name eq 'AccountManager' } @auth ), 'can find right authorization' );

    my @user_auths = $ysm_ws->getAuthorizedUsersByAccountID( accountIDs => [ $ysm_ws->account ] );

    my $find = 0;
    foreach my $user_auth ( @user_auths ) {
        if ( $user_auth->username eq $self->common_test_data( 'test_user' ) and 
                 $user_auth->role->name eq 'AccountManager' ) {
            $find = 1;
            last;
        }
    }
    is( $find, 1, 'find authorized user in account' );

    @user_auths = $ysm_ws->getAuthorizedUsersByMasterAccountID;
    $find = 0;
    foreach my $user_auth ( @user_auths ) {
        if ( $user_auth->username eq $ysm_ws->username and 
                 $user_auth->role->name eq 'MasterAccountAdministrator' ) {
            $find = 1;
            last;
        }
    }
    is( $find, 1, 'find authorized user in master account' );

    ok( $ysm_ws->deleteAuthorizationForUser(
        username      => $self->common_test_data( 'test_user' ),
        authorization => Yahoo::Marketing::Authorization->new
                                                        ->accountID( $ysm_ws->account )
                                                        ->accountType( 'Account' )
                                                        ->role( $role ),
        ), 'can delete authorization' );

    $role = Yahoo::Marketing::Role->new->name( 'Analyst' );

    ok( $ysm_ws->addAuthorizationForUser(
                 username      => $self->common_test_data( 'test_user' ),
                 authorization => Yahoo::Marketing::Authorization->new
                                                                 ->accountID( $ysm_ws->account )
                                                                 ->accountType( 'Account' )
                                                                 ->role( $role ),
             ), 'can add authorization' );
}

sub test_add_credit_card : Test(3) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );

    my @payment_methods = $ysm_ws->getPaymentMethods;
    unless ( @payment_methods ) {
        my $payment_method_id = $ysm_ws->addCreditCard(
            billingUserInfo => Yahoo::Marketing::BillingUser->new
                                                            ->email( 'test@yahoo-inc.com' )
                                                            ->firstName( 'John' )
                                                            ->lastName( 'Smith' )
                                                            ->phone( '212-555-1234' ),
            billingAddress  => Yahoo::Marketing::Address->new
                                                        ->address1('123 Main Street')
                                                        ->city('New York')
                                                        ->country('US')
                                                        ->postalCode( '10012' )
                                                        ->state( 'NY' ),
            cc              => Yahoo::Marketing::CreditCardInfo->new
                                                               ->cardNumber( '347688405216148' )
                                                               ->cardType( 'Amex' )
                                                               ->expMonth( '1' )
                                                               ->expYear( '2015' )
                                                               ->securityCode( '1234' ),
        );
        @payment_methods = $ysm_ws->getPaymentMethods;
    }

    ok( @payment_methods );

    my $payment_method = $payment_methods[0];
    my $old_address = $payment_method->billingAddress;
    my $id = $ysm_ws->updateCreditCard(
        paymentMethodID => $payment_method->ID,
        billingUserInfo => $payment_method->billingUser,
        billingAddress  => $payment_method->billingAddress->address1('456 Park Ave'),
        cc              => Yahoo::Marketing::CreditCardInfo->new->expYear('2016'),
        updateAll       => 'false',
    );
    @payment_methods = $ysm_ws->getPaymentMethods;
    ( $payment_method ) = grep { $_->ID eq $id } @payment_methods;

    is( $payment_method->billingAddress->address1, '456 Park Ave', 'address is right' );
    is( ref $payment_method->expirationDate, 'DateTime', 'expiration date is DateTime object' );

    $ysm_ws->updateCreditCard(
        paymentMethodID => $payment_method->ID,
        billingUserInfo => $payment_method->billingUser,
        billingAddress  => $payment_method->billingAddress->address1('123 Main Street'),
        cc              => Yahoo::Marketing::CreditCardInfo->new->cardNumber( '' ),
        updateAll       => 'false',
    );
}

sub test_add_user : Test(1) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );
    my $new_user_name = $self->_make_username;
    $ysm_ws->addUser(
        username => $new_user_name,
        user     => Yahoo::Marketing::User->new
                                          ->email( $new_user_name . '@yahoo-inc.com' )
                                          ->firstName( 'test' )
                                          ->lastName( 'user' )
                                          ->locale( 'en_US' )
                                          ->timezone( 'America/Los_Angeles' )
                                          ->workPhone( '888-555-1234' ),
        address  => Yahoo::Marketing::Address->new
                                             ->address1('123 Sunshine Street')
                                             ->city('Sunnyvale')
                                             ->country('US')
                                             ->postalCode( '94089' )
                                             ->state( 'CA' )
    );

    is( $ysm_ws->getUserStatus( username => $new_user_name ), 'Staged', 'status is right' );
}

sub test_enable_disable_user_and_get_user_status : Test(4) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    return 'no other active user we can test on this function.' unless $self->common_test_data( 'test_user' );

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );

    ok( $ysm_ws->disableUser( username => $self->common_test_data( 'test_user' ) ), 'can disable user' );
    is( $ysm_ws->getUserStatus( username => $self->common_test_data( 'test_user' ) ), 'Disabled', 'status is right' );
    ok( $ysm_ws->enableUser( username => $self->common_test_data( 'test_user' ) ), 'can enable user' );
    is( $ysm_ws->getUserStatus( username => $self->common_test_data( 'test_user' ) ), 'Active', 'status is right' );
}

sub test_get_available_roles_by_account_id : Test(2) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );
    my @roles = $ysm_ws->getAvailableRolesByAccountID(
        accountType => 'MasterAccount',
        accountID   => $ysm_ws->master_account,
    );

    is( join('', map { $_->name } @roles), 'MasterAccountAdministrator', 'roles are right' );

    @roles = $ysm_ws->getAvailableRolesByAccountID(
        accountType => 'Account',
        accountID   => $ysm_ws->account,
    );

    is( join('', sort {$a cmp $b} map { $_->name } @roles), 'AccountManagerAnalystCampaignManager', 'roles are right' );
}

sub test_get_capabilities_for_role : Test(1) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );
    my @capabilities = $ysm_ws->getCapabilitiesForRole(
        role => Yahoo::Marketing::Role->new->name( 'MasterAccountAdministrator' ),
    );

    ok( @capabilities, 'capabilities are right' );
}

sub test_get_and_update_my_address : Test(3) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );
    my $address = $ysm_ws->getMyAddress;

    ok( $address );

    my $new_address = $address;
    $ysm_ws->updateMyAddress(
        address => $new_address->address1( '789 Grand Ave' ),
        updateAll => 'false',
    );

    is( $ysm_ws->getMyAddress->address1, '789 Grand Ave', 'address is right' );

    $ysm_ws->updateMyAddress(
        address => $address,
        updateAll => 'true',
    );

    is( $ysm_ws->getMyAddress->address1, $address->address1, 'address is right' );
}

sub test_get_my_authorization : Test(2) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );
    my @auths = $ysm_ws->getMyAuthorizations;

    ok( @auths );

    my $found = 0;
    foreach my $auth ( @auths ) {
        $found++ if $auth->accountID eq $ysm_ws->account or $auth->accountID eq $ysm_ws->master_account;
    }

    ok( $found, 'get auth right' );
}

sub test_get_and_update_my_user_info : Test(6) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );
    my $user = $ysm_ws->getMyUserInfo;

    ok( $user, 'can get my user info' );

    $ysm_ws->updateMyUserInfo(
        userInfo => $user->workPhone( '212-555-7890' ),
        updateAll => 'false',
    );
    $ysm_ws->updateMyEmail( email => 'test@yahoo-inc.com' );
    my $fetched_user = $ysm_ws->getMyUserInfo;

    is( $fetched_user->workPhone, '212-555-7890', 'work phone updated' );
    is( $fetched_user->email, 'test@yahoo-inc.com' );
    is( $ysm_ws->getUserEmail( username => $ysm_ws->username ), 'test@yahoo-inc.com', 'email is right' );

    $ysm_ws->updateMyUserInfo(
        userInfo => $user,
        updateAll => 'true',
    );
    my $fetched_user2 = $ysm_ws->getMyUserInfo;

    is( $fetched_user2->workPhone, $user->workPhone, 'work phone update right' );
    is( $fetched_user2->email, $user->email, 'email is right' );
}

sub test_get_and_update_user_address : Test(3) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    return 'no other active user we can test on this function.' unless $self->common_test_data( 'test_user' );

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );
    my $address = $ysm_ws->getUserAddress( username => $self->common_test_data( 'test_user' ) );

    ok( $address );

    my $new_address = $address;
    $ysm_ws->updateUserAddress(
        username => $self->common_test_data( 'test_user' ),
        address => $new_address->address1( '789 Grand Ave' ),
        updateAll => 'false',
    );

    is( $ysm_ws->getUserAddress( username => $self->common_test_data( 'test_user' ) )->address1, '789 Grand Ave', 'address is right' );

    $ysm_ws->updateUserAddress(
        username => $self->common_test_data( 'test_user' ),
        address => $address,
        updateAll => 'true',
    );

    is( $ysm_ws->getUserAddress( username => $self->common_test_data( 'test_user' ) )->address1, $address->address1, 'address is right' );
}

sub test_get_and_update_user_info : Test(3) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    return 'no other active user we can test on this function.' unless $self->common_test_data( 'test_user' );

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );
    my $user = $ysm_ws->getUserInfo( username => $self->common_test_data( 'test_user' ) );

    ok( $user );

    my $new_user = $user;
    $ysm_ws->updateUserInfo(
        username => $self->common_test_data( 'test_user' ),
        userInfo => $new_user->workPhone( '818-555-7890' )->email( 'test@yahoo-inc.com' ),
        updateAll => 'true',
    );
    my $fetched_user = $ysm_ws->getUserInfo( username => $self->common_test_data( 'test_user' ) );

    is( $fetched_user->workPhone, '818-555-7890', 'work phone is right' );

    $ysm_ws->updateUserInfo(
        username => $self->common_test_data( 'test_user' ),
        userInfo => $user,
        updateAll => 'true',
    );
    my $fetched_user2 = $ysm_ws->getUserInfo( username => $self->common_test_data( 'test_user' ) );

    is( $fetched_user2->workPhone, $user->workPhone, 'phone is right' );
}

sub test_test_username : Test(2) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );

    # we know this username should not be available, we're using it!
    is( $ysm_ws->testUsername( username => $ysm_ws->username ), 'false', 'our username is not available' );

    # we hope this randomish username is available
    is( $ysm_ws->testUsername( username => $self->_make_username ), 'true', 'randomish username is available' );
}

sub startup_test_user_management_service : Test(startup) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    diag("preparing test data...");

    $self->common_test_data( 'test_user', $self->get_user ) unless defined $self->common_test_data( 'test_user' );
}

sub cleanup_user : Test(shutdown) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    diag("cleaning test data...");

    $self->common_test_data( 'test_user', undef );
}


sub _make_username {
    my $self = shift;

    my $time = time();
    return 'tu'.substr( $time, length($time) - 8, length( $time ) );
}

sub get_user {
    my $self = shift;

    my $ysm_ws = Yahoo::Marketing::UserManagementService->new->parse_config( section => $section );

    my @user_names = $ysm_ws->getUsersInCompany;
    foreach my $username ( @user_names ) {
        next if $username eq $ysm_ws->username;
        return $username if $ysm_ws->getUserStatus( username => $username ) eq 'Active';
    }
    # this company has no more active user to test.
    return;
}


1;


__END__

# addUser
# addAuthorizationsForUser
# addAuthorizationForUser
# getAvailableRolesByAccountID
# testUsername
# getMyUserInfo
# getMyAddress
# updateMyUserInfo
# updateMyAddress
# updateMyEmail
# getMyAuthorizations
# updateUserInfo
# updateUserAddress
# getUserInfo
# getUserAddress
# getUserEmail
# getUserStatus
# enableUser
# disableUser
# getAuthorizationsForUser
# getUsersInCompany
# getAuthorizedUsersByMasterAccountID
# getAuthorizedUsersByAccountID
# deleteAuthorizationsForUser
# deleteAuthorizationForUser
# deleteUser
# deleteUsers
# updateMyPassword
# resetUserPassword
# getCapabilitiesForRole
# addCreditCard
# updateCreditCard
# getPaymentMethods



