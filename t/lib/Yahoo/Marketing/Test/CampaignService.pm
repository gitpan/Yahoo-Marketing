package Yahoo::Marketing::Test::CampaignService;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/ Yahoo::Marketing::Test::PostTest /;

use Test::More;

use Yahoo::Marketing::Campaign;
use Yahoo::Marketing::CampaignService;
use Yahoo::Marketing::CampaignOptimizationGuidelines;

my $section = 'sandbox';

sub startup_test_campaign_service : Test(startup) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    diag("preparing test data...");

    $self->common_test_data( 'test_campaign', $self->create_campaign ) unless defined $self->common_test_data( 'test_campaign' );
    $self->common_test_data( 'test_campaigns', [$self->create_campaigns] ) unless defined $self->common_test_data( 'test_campaigns' );
}


sub shutdown_test_campaign_service : Test(shutdown) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    diag("cleaning test data...");
    $self->cleanup_campaign;
    $self->cleanup_campaigns;
}


sub test_get_campaign : Test(3) { 
    my ( $self ) = @_;
    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my $campaign = $self->common_test_data( 'test_campaign' );

    my $fetched_campaign = $ysm_ws->getCampaign( campaignID => $campaign->ID );

    ok( $fetched_campaign );

    is( $fetched_campaign->name, $campaign->name, 'name is right' );
    is( $fetched_campaign->ID,   $campaign->ID,   'ID is right' );
}

sub test_update_campaign : Test(21) {
    my ( $self ) = @_;
    return 'not running post tests' unless $self->run_post_tests;

    my $campaign = $self->common_test_data( 'test_campaign' );

    my $formatter = DateTime::Format::W3CDTF->new;
    my $datetime = DateTime->now;
    $datetime->set_time_zone( 'America/Chicago' );

    my $start_datetime = $formatter->format_datetime( $datetime );


    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );
    my $update_campaign_response = $ysm_ws->updateCampaign( 
                                        campaign  => $campaign->name( "updated campaign $$" )
                                                              ->watchON( 'true' ) 
                                                              ->contentMatchON( 'true' ) 
                                                              ->advancedMatchON( 'true' ) 
                                                              ->sponsoredSearchON( 'true' ) 
                                                              ->startDate( $start_datetime ),
                                        updateAll => 'true',
                                    );

    ok( $update_campaign_response );
    is( $update_campaign_response->operationSucceeded, 'true' );
    my $updated_campaign = $update_campaign_response->campaign;
    ok( $updated_campaign);
    is( $updated_campaign->name,                    "updated campaign $$", 'name is right' );
    is( $updated_campaign->ID,                      $campaign->ID,   'ID is right' );
    is( $updated_campaign->watchON,                 'true',          'watch on is true' );
    is( $updated_campaign->contentMatchON,          'true',          'content match on is true' );
    is( $updated_campaign->advancedMatchON,         'true',          'advanced match on is true' );
    is( $updated_campaign->sponsoredSearchON,       'true',          'sponsored search  on is true' );
    is( DateTime->compare( $formatter->parse_datetime( $updated_campaign->startDate ),
                           $datetime ),             0,               'start date is right' );

    is( $ysm_ws->last_command_group, 'Marketing', 'last command group gets set correctly' );
    like( $ysm_ws->remaining_quota, qr/^\d+$/, 'remaining quota looks right' );

    $update_campaign_response = $ysm_ws->updateCampaign( campaign  => $updated_campaign->watchON( 'false' )
                                                                               ->contentMatchON( 'false' ) 
                                                                               ->advancedMatchON( 'false' ) 
                                                                               ->sponsoredSearchON( 'true' ),
                                                         updateAll => 'true',
                                 );
    is( $update_campaign_response->operationSucceeded, 'true' );
    $updated_campaign = $update_campaign_response->campaign;
    is( $updated_campaign->watchON,                 'false',          'watch on is false' );
    is( $updated_campaign->contentMatchON,          'false',          'content match on is false' );
    is( $updated_campaign->advancedMatchON,         'false',          'advanced match on is false' );
    is( $updated_campaign->sponsoredSearchON,       'true',          'sponsored search  on is false' );

    $datetime->subtract( years => 1 );
    $start_datetime = $formatter->format_datetime( $datetime );

    $update_campaign_response = $ysm_ws->updateCampaign( campaign  => $updated_campaign->startDate( $start_datetime ), 
                                                         updateAll => 'true',
                                                       );
    is( $update_campaign_response->operationSucceeded, 'false' ); # cannot set startDate to past time.
    ok( $update_campaign_response->errors );

    $update_campaign_response = $ysm_ws->updateCampaign( campaign  => $updated_campaign->endDate( $start_datetime ),
                                                         updateAll => 'true',
                                                       );
    is( $update_campaign_response->operationSucceeded, 'false' ); # cannot set endDate before startDate.
    ok( $update_campaign_response->errors );
}

sub test_can_add_campaign : Test(4) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $campaign = $self->create_campaign;

    ok( $campaign );

    like( $campaign->name, qr/^test campaign \d+$/, 'name looks right' );
    like( $campaign->ID, qr/^[\d]+$/, 'ID is numeric' );

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    ok( $ysm_ws->deleteCampaign(
                     campaignID => $campaign->ID,
                 ),
        'can delete campaign'
    );
}


sub test_can_get_campaign_ad_group_count : Test(6) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $campaign = $self->common_test_data( 'test_campaign' );

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my $count = $ysm_ws->getCampaignAdGroupCount(
                             campaignID     => $campaign->ID,
                             includeDeleted => 'false',
                         );
    is( $count, '0', 'AdGroup count is right' );

    my $ad_group = Yahoo::Marketing::AdGroup->new
                                            ->campaignID( $campaign->ID )
                                            ->name( 'test ad group '.$$ )
                                            ->status( 'On' )
                                            ->contentMatchON( 'true' )
                                            ->contentMatchMaxBid( '0.18' )
                                            ->sponsoredSearchON( 'true' )
                                            ->sponsoredSearchMaxBid( '0.28' )
                                            ->adAutoOptimizationON( 'false' )
                   ;
    my $ad_group_service = Yahoo::Marketing::AdGroupService->new->parse_config( section => $section );
    my $add_ad_group_response = $ad_group_service->addAdGroup( adGroup => $ad_group );
    ok( not $add_ad_group_response->errors );

    $count = $ysm_ws->getCampaignAdGroupCount(
                             campaignID     => $campaign->ID,
                             includeDeleted => 'false',
                         );
    is( $count, '1', 'AdGroup count is right' );

    ok( $ad_group_service->deleteAdGroup( adGroupID => $add_ad_group_response->adGroup->ID ) );

    $count = $ysm_ws->getCampaignAdGroupCount(
                             campaignID     => $campaign->ID,
                             includeDeleted => 'false',
                         );
    is( $count, '0', 'AdGroup count is right' );

    $count = $ysm_ws->getCampaignAdGroupCount(
                             campaignID     => $campaign->ID,
                             includeDeleted => 'true',
                         );
    is( $count, '1', 'AdGroup count is right' );
}

sub test_can_get_campaigns_by_account_id : Test(1) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my @campaigns = $ysm_ws->getCampaignsByAccountID(
        accountID      => $ysm_ws->account,
        includeDeleted => 'false',
    );

    ok( scalar @campaigns );
}


sub test_can_update_campaigns : Test(13) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my @campaigns = @{ $self->common_test_data( 'test_campaigns' ) };

    ok( @campaigns );

    my @response = $ysm_ws->updateCampaigns( campaigns => [ $campaigns[0]->name( "updated campaign $$ 1" ),
                                                            $campaigns[1]->name( "updated campaign $$ 2" ),
                                                          ],
                                             updateAll => 'true',
                                           );

    ok( @response );
    ok( not $response[0]->errors );
    ok( not $response[1]->errors );

    for my $index ( 0..1 ) { 
        my $fetched_campaign = $ysm_ws->getCampaign( campaignID => $campaigns[ $index ]->ID );

        my $campaign_name_index = $index + 1;

        ok( $fetched_campaign );
        is( $fetched_campaign->ID,   $campaigns[ $index ]->ID,   'ID is right' );   # heck, better be, we just got it by id
        is( $fetched_campaign->name, "updated campaign $$ $campaign_name_index", 'name is right' );
    }

    # check the third one [2]! to make sure it wasn't changed
    my $fetched_campaign = $ysm_ws->getCampaign( campaignID => $campaigns[2]->ID );

    ok( $fetched_campaign );
    is( $fetched_campaign->name, $campaigns[2]->name, 'name is right' );
    is( $fetched_campaign->ID,   $campaigns[2]->ID,   'ID is right' );

}


sub test_can_get_campaigns : Test(4) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my @campaigns = @{ $self->common_test_data( 'test_campaigns' ) };

    ok( @campaigns );

    my @fetched_campaigns = $ysm_ws->getCampaigns( campaignIDs => [ $campaigns[0]->ID,
                                                                    $campaigns[1]->ID,
                                                                  ]
                                     );

    is( scalar @fetched_campaigns, 2, 'got correct number of campaigns returned' );

    like( $fetched_campaigns[0]->name, qr/^test campaign \d+ 1$/, 'name looks right' );
    like( $fetched_campaigns[0]->ID, qr/^[\d]+$/, 'ID is numeric' );

}


sub test_can_update_status_for_campaigns : Test(4) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my @campaigns = @{ $self->common_test_data( 'test_campaigns' ) };

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    $ysm_ws->updateStatusForCampaigns(
                 campaignIDs => [ $campaigns[0]->ID, $campaigns[1]->ID ],
                 status      => 'Off',
             );

    is( $ysm_ws->getCampaign( campaignID => $campaigns[0]->ID )->status, 'Off' );
    is( $ysm_ws->getCampaign( campaignID => $campaigns[1]->ID )->status, 'Off' );

    $ysm_ws->updateStatusForCampaigns(
                 campaignIDs => [ $campaigns[0]->ID, $campaigns[1]->ID ],
                 status      => 'On',
             );

    is( $ysm_ws->getCampaign( campaignID => $campaigns[0]->ID )->status, 'On' );
    is( $ysm_ws->getCampaign( campaignID => $campaigns[1]->ID )->status, 'On' );
}


sub test_can_get_status_for_campaign : Test(1) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $campaign = $self->common_test_data( 'test_campaign' );

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my $status = $ysm_ws->getStatusForCampaign( campaignID => $campaign->ID, );

    ok( $status, 'Can get campaign status');
}

sub test_can_get_campaign_keyword_count : Test(1) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $campaign = $self->common_test_data( 'test_campaign' );

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my $count = $ysm_ws->getCampaignKeywordCount(
        campaignID     => $campaign->ID,
        includeDeleted => 'false',
    );

    like( $count, qr/^[\d]+$/, 'Campaign Keyword Count is numeric' );
}


sub test_can_delete_campaign : Test(2) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $campaign = $self->create_campaign;

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my $response = $ysm_ws->deleteCampaign(
                       campaignID => $campaign->ID,
                   );

    is( $response->operationSucceeded, 'true' );

    my $fetched_campaign = $ysm_ws->getCampaign( campaignID => $campaign->ID, );

    is( $fetched_campaign->status, 'Deleted', 'campaign has Deleted status' );
}

sub test_can_set_get_delete_geographic_location_for_campaign : Test(16) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $campaign = $self->create_campaign;

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my $response = $ysm_ws->setGeographicLocationForCampaign(
        campaignID => $campaign->ID,
        geoStrings => [ 'new york' ],
    );

    ok( $response );

    is( ref $response, 'Yahoo::Marketing::SetGeographicLocationResponse' );
    is( $response->setSucceeded, 'false' );
    ok( not $response->stringsWithNoMatches );
    is( ref ($response->ambiguousMatches->[0]), 'Yahoo::Marketing::AmbiguousGeoMatch' );
    is( $response->ambiguousMatches->[0]->geoString, 'new york' );
    ok( @{ $response->ambiguousMatches->[0]->possibleMatches } );

    my $new_response = $ysm_ws->setGeographicLocationForCampaign(
        campaignID => $campaign->ID,
        geoStrings => [ $response->ambiguousMatches->[0]->possibleMatches->[0] ],
    );

    ok( $new_response );
    is( $new_response->setSucceeded, 'true' );
    ok( not $new_response->stringsWithNoMatches );
    ok( not $new_response->ambiguousMatches );

    my @locations = $ysm_ws->getGeographicLocationForCampaign(
        campaignID => $campaign->ID,
    );

    ok( @locations );
    like( $locations[0], qr/New York/ );

    ok ( $ysm_ws->deleteGeographicLocationFromCampaign( campaignID => $campaign->ID ) );

    @locations = $ysm_ws->getGeographicLocationForCampaign(
        campaignID => $campaign->ID,
    );

    # if no geo location set, the action returns empty.
    ok( not @locations );
    ok( $ysm_ws->deleteCampaign( campaignID => $campaign->ID ) );
}

sub test_set_get_delete_geographic_location_for_campaign_works_for_unambiguous_match : Test(3) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $campaign = $self->create_campaign;

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my $response = $ysm_ws->setGeographicLocationForCampaign(
        campaignID => $campaign->ID,
        geoStrings => [ 'New York, NY, United States' ],
    );

    ok( $response );

    is( ref $response, 'Yahoo::Marketing::SetGeographicLocationResponse' );
    is( $response->setSucceeded, 'true' );
}

sub test_set_get_delete_geographic_location_for_campaign_doesnt_fail_for_bad_location : Test(5) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $silly_geo_string = 'this is a really silly geo string that shouldnt return any ambiguous matches at all';

    my $campaign = $self->create_campaign;

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my $response = $ysm_ws->setGeographicLocationForCampaign(
        campaignID => $campaign->ID,
        geoStrings => [ $silly_geo_string ],
    );

    ok( $response );

    is( ref $response, 'Yahoo::Marketing::SetGeographicLocationResponse' );
    is( $response->setSucceeded, 'false' );
    is( $response->stringsWithNoMatches, $silly_geo_string );

    ok( not $response->ambiguousMatches );
}

sub test_can_set_and_get_optimization_guidelines_for_campaign : Test(5) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $campaign = $self->common_test_data( 'test_campaign' );

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my $campaignOptimizationGuidelines = Yahoo::Marketing::CampaignOptimizationGuidelines->new
                                             ->campaignID( $campaign->ID )
                                             ->conversionMetric( 'Revenue' )
                                             ->ROAS( 100.0 )                        # ROAS (return on ad spend) is required when conversionMetric is 'Revenue'.  % value
                                             ->averageConversionRate( 0.04 )        # also required as above reason
                                             ->averageRevenuePerConversion( 0.03 )  # also required as above reason
                                             ->CPC( 0.1 )
                                             ->CPM( 0.1 )
                                             ->impressionImportance( 'Low' )
                                             ->leadImportance( 'Low' )
                                             ->taggedForConversion( 1 )
                                             ->taggedForRevenue( 0 )
                                             ->maxBid( 1.00 )
                                             ->bidLimitHeadroom( 10.0 )             #  % value
                                             ->monthlySpendRate( 100.00 )
    ;

    $ysm_ws->setCampaignOptimizationON(
                 campaignID             => $campaign->ID,
                 campaignOptimizationON => 'true',
             );

    my $response = $ysm_ws->setOptimizationGuidelinesForCampaign(
                       optimizationGuidelines => $campaignOptimizationGuidelines,
                   );

    is( $response->operationSucceeded, 'true' );

    my $updated_campaign_optimization_guidelines = $response->campaignOptimizationGuidelines;

    is( $updated_campaign_optimization_guidelines->conversionMetric, 'Revenue' );
    is( $updated_campaign_optimization_guidelines->maxBid, '1.0' );
    is( $updated_campaign_optimization_guidelines->impressionImportance, 'Low' );
    is( $updated_campaign_optimization_guidelines->bidLimitHeadroom, '10.0' );
}

sub test_can_get_campaigns_by_account_id_by_campaign_status : Test(1) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my @campaigns = $ysm_ws->getCampaignsByAccountIDByCampaignStatus(
                                 accountID => $ysm_ws->account,
                                 status    => 'On',
                             );

    ok(scalar @campaigns);
}


sub test_can_add_campaigns : Test(8) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my @added_campaigns = $self->create_campaigns;

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    ok( scalar @added_campaigns );

    like( $added_campaigns[0]->name, qr/^test campaign \d+ 1$/, 'name looks right' );
    like( $added_campaigns[0]->ID, qr/^[\d]+$/, 'ID is numeric' );

    like( $added_campaigns[1]->name, qr/^test campaign \d+ 2$/, 'name looks right' );
    like( $added_campaigns[1]->ID, qr/^[\d]+$/, 'ID is numeric' );

    like( $added_campaigns[2]->name, qr/^test campaign \d+ 3$/, 'name looks right' );
    like( $added_campaigns[2]->ID, qr/^[\d]+$/, 'ID is numeric' );

    ok( $ysm_ws->deleteCampaigns( campaignIDs => [ map { $_->ID } @added_campaigns ] ) );
}

sub test_add_campaigns_doesnt_add_if_one_is_bad : Test(3) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $formatter = DateTime::Format::W3CDTF->new;
    my $datetime = DateTime->now;
    $datetime->set_time_zone( 'America/Chicago' );

    my $start_datetime = $formatter->format_datetime( $datetime );

    $datetime->add( years => 1 );
    my $end_datetime   = $formatter->format_datetime( $datetime );

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my $campaign1 = Yahoo::Marketing::Campaign->new
                                              ->startDate( $start_datetime )
                                              ->endDate(   $end_datetime )
                                              ->name( 'test good campaign '.$$.' 1' )
                                              ->status( 'On' )
                                              ->accountID( $ysm_ws->account )
                    ;
    my $campaign2 = Yahoo::Marketing::Campaign->new   # no start date
                                              ->endDate(   $end_datetime )
                                              ->name( 'test bad campaign '.$$.' 2' )
                                              ->status( 'On' )
                                              ->accountID( $ysm_ws->account )
                    ;
    my $campaign3 = Yahoo::Marketing::Campaign->new
                                              ->startDate( $start_datetime )
                                              ->endDate(   $end_datetime )
                                              ->name( 'test good campaign '.$$.' 3' )
                                              ->status( 'On' )
                                              ->accountID( $ysm_ws->account )
                    ;

    eval { $ysm_ws->addCampaigns( campaigns => [ $campaign1, $campaign2, $campaign3 ] ); };

    like( $@, qr/A required field startDate is missing/m, 'add campaigns fails as expected' );
    my @campaigns = $ysm_ws->getCampaignsByAccountID(
        accountID      => $ysm_ws->account,
        includeDeleted => 'false',
    );

    ok( ( not grep { /^test bad/ } map { $_->name } @campaigns ), 'bad campaign was not added' );
    ok( ( not grep { /^test good/ } map { $_->name } @campaigns ), 'good campaigns were not added either' );

}

sub test_can_update_status_for_campaign : Test(4) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $campaign = $self->common_test_data( 'test_campaign' );

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );
    $ysm_ws->updateStatusForCampaign(
                 campaignID => $campaign->ID,
                 status     => 'Off',
             );

    my $fetched_campaign = $ysm_ws->getCampaign( campaignID => $campaign->ID );

    ok( $fetched_campaign );

    is( $fetched_campaign->status, 'Off' );


    $ysm_ws->updateStatusForCampaign(
                 campaignID => $campaign->ID,
                 status     => 'On',
             );

    $fetched_campaign = $ysm_ws->getCampaign( campaignID => $campaign->ID );

    ok( $fetched_campaign );
    is( $fetched_campaign->status, 'On' );
}

sub test_can_delete_campaigns : Test(4) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $campaign1 = $self->create_campaign;
    my $campaign2 = $self->create_campaign;

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my @responses = $ysm_ws->deleteCampaigns(
                        campaignIDs => [ $campaign1->ID, $campaign2->ID ],
                    );

    foreach my $response ( @responses ){
        is( $response->operationSucceeded, 'true' );
    }

    my @fetched_campaigns = $ysm_ws->getCampaigns(
                                         campaignIDs => [ $campaign1->ID, $campaign2->ID ],
                                     );

    is( $fetched_campaigns[0]->status, 'Deleted', 'first campaign has Deleted status' );
    is( $fetched_campaigns[1]->status, 'Deleted', 'second campaign has Deleted status' );
}



sub test_update_campaigns_response_with_multiple_errors_doesnt_die_incorrectly : Test(2) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );
    $ysm_ws->use_location_service(0);

    my @campaigns = @{ $self->common_test_data( 'test_campaigns' ) };

    eval { $ysm_ws->updateCampaigns( campaigns => [ $campaigns[0]->name( "updated campaign $$ 1" ),
                                                    $campaigns[1]->status( 'foo' ),
                                                    $campaigns[2]->status( 'bar' ),
                                                  ],
                                     updateAll => 'true',
                                   );
         };

    my $die_message = $@;

    ok( $die_message, 'we died' );        
    like( $die_message, qr/Message: Enumeration value "foo" is not recognized\./,'die message looks right' );
}


1;

