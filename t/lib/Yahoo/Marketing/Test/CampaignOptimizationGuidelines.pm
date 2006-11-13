package Yahoo::Marketing::Test::CampaignOptimizationGuidelines;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::CampaignOptimizationGuidelines;

sub test_can_create_campaign_optimization_guidelines_and_set_all_fields : Test(21) {

    my $campaign_optimization_guidelines = Yahoo::Marketing::CampaignOptimizationGuidelines->new
                                                                                           ->CPA( 'cpa' )
                                                                                           ->CPC( 'cpc' )
                                                                                           ->CPM( 'cpm' )
                                                                                           ->ROAS( 'roas' )
                                                                                           ->accountID( 'account id' )
                                                                                           ->averageConversionRate( 'average conversion rate' )
                                                                                           ->averageRevenuePerConversion( 'average revenue per conversion' )
                                                                                           ->campaignID( 'campaign id' )
                                                                                           ->conversionImportance( 'conversion importance' )
                                                                                           ->conversionMetric( 'conversion metric' )
                                                                                           ->impressionImportance( 'impression importance' )
                                                                                           ->leadImportance( 'lead importance' )
                                                                                           ->maxBid( 'max bid' )
                                                                                           ->monthlySpendRate( 'monthly spend rate' )
                                                                                           ->sponsoredSearchMinPosition( 'sponsored search min position' )
                                                                                           ->sponsoredSearchMinPositionImportance( 'sponsored search min position importance' )
                                                                                           ->taggedForConversion( 'tagged for conversion' )
                                                                                           ->taggedForRevenue( 'tagged for revenue' )
                                                                                           ->createTimestamp( 'create timestamp' )
                                                                                           ->lastUpdateTimestamp( 'last update timestamp' )
                   ;

    ok( $campaign_optimization_guidelines );

    is( $campaign_optimization_guidelines->CPA, 'cpa', 'can get cpa' );
    is( $campaign_optimization_guidelines->CPC, 'cpc', 'can get cpc' );
    is( $campaign_optimization_guidelines->CPM, 'cpm', 'can get cpm' );
    is( $campaign_optimization_guidelines->ROAS, 'roas', 'can get roas' );
    is( $campaign_optimization_guidelines->accountID, 'account id', 'can get account id' );
    is( $campaign_optimization_guidelines->averageConversionRate, 'average conversion rate', 'can get average conversion rate' );
    is( $campaign_optimization_guidelines->averageRevenuePerConversion, 'average revenue per conversion', 'can get average revenue per conversion' );
    is( $campaign_optimization_guidelines->campaignID, 'campaign id', 'can get campaign id' );
    is( $campaign_optimization_guidelines->conversionImportance, 'conversion importance', 'can get conversion importance' );
    is( $campaign_optimization_guidelines->conversionMetric, 'conversion metric', 'can get conversion metric' );
    is( $campaign_optimization_guidelines->impressionImportance, 'impression importance', 'can get impression importance' );
    is( $campaign_optimization_guidelines->leadImportance, 'lead importance', 'can get lead importance' );
    is( $campaign_optimization_guidelines->maxBid, 'max bid', 'can get max bid' );
    is( $campaign_optimization_guidelines->monthlySpendRate, 'monthly spend rate', 'can get monthly spend rate' );
    is( $campaign_optimization_guidelines->sponsoredSearchMinPosition, 'sponsored search min position', 'can get sponsored search min position' );
    is( $campaign_optimization_guidelines->sponsoredSearchMinPositionImportance, 'sponsored search min position importance', 'can get sponsored search min position importance' );
    is( $campaign_optimization_guidelines->taggedForConversion, 'tagged for conversion', 'can get tagged for conversion' );
    is( $campaign_optimization_guidelines->taggedForRevenue, 'tagged for revenue', 'can get tagged for revenue' );
    is( $campaign_optimization_guidelines->createTimestamp, 'create timestamp', 'can get create timestamp' );
    is( $campaign_optimization_guidelines->lastUpdateTimestamp, 'last update timestamp', 'can get last update timestamp' );

};



1;

