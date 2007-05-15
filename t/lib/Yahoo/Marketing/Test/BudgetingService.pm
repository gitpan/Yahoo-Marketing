package Yahoo::Marketing::Test::BudgetingService;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/ Yahoo::Marketing::Test::PostTest /;
use Test::More;
use Module::Build;

use Yahoo::Marketing::BudgetingService;

my $section = 'sandbox';

sub test_account_daily_spend_limit : Test(4) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::BudgetingService->new->parse_config( section => $section );

    $ysm_ws->updateAccountDailySpendLimit(
                 accountID => $ysm_ws->account,
                 amount    => '100.01',
             );

    my $spend_status = $ysm_ws->getAccountDailySpendLimitStatus( accountID => $ysm_ws->account );

    ok( $spend_status );
    is( $spend_status, 'true' );

    my $spend_limit = $ysm_ws->getAccountDailySpendLimit( accountID => $ysm_ws->account );
    ok( $spend_limit );
    is( $spend_limit, '100.01' );

}

sub test_campaign_daily_spend_limit : Test(7) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $campaign = $self->common_test_data( 'test_campaign' );
    is( $campaign->campaignOptimizationON, 'false' );

    #NOTE: only if campaignOptimizationON is off can following features be used.
    my $ysm_ws = Yahoo::Marketing::BudgetingService->new->parse_config( section => $section );

    my $spend_status = $ysm_ws->getCampaignDailySpendLimitStatus( campaignID => $campaign->ID );

    ok( $spend_status );
    is( $spend_status, 'false' );

    $ysm_ws->updateCampaignDailySpendLimit(
                 campaignID => $campaign->ID,
                 amount     => '200.01',
             );

    $ysm_ws->updateCampaignDailySpendLimitStatus(
                 campaignID => $campaign->ID,
                 status     => 'true',
             );

    $spend_status = $ysm_ws->getCampaignDailySpendLimitStatus( campaignID => $campaign->ID );

    ok( $spend_status );
    is( $spend_status, 'true' );

    my $spend_limit = $ysm_ws->getCampaignDailySpendLimit( campaignID => $campaign->ID );
    ok( $spend_limit );
    is( $spend_limit, '200.01' );
}


sub startup_test_budgeting_service : Test(startup) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    diag("preparing test data...");

    $self->common_test_data( 'test_campaign', $self->create_campaign ) unless defined $self->common_test_data( 'test_campaign' );
}

sub shutdown_test_budgeting_service : Test(shutdown) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    diag("cleaning test data...");
    $self->cleanup_campaign;
}

1;

__END__

# getAccountDailySpendLimit
# updateAccountDailySpendLimit
# getCampaignDailySpendLimit
# updateCampaignDailySpendLimit
# enableAccountDailySpendLimit
# getAccountDailySpendLimitStatus
# getCampaignDailySpendLimitStatus
# updateCampaignDailySpendLimitStatus
