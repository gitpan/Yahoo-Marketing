package Yahoo::Marketing::TEST::ForecastService;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use base qw/ Yahoo::Marketing::TEST::PostTest /;
use Test::More;
use Module::Build;

use Yahoo::Marketing::ForecastService;
use Yahoo::Marketing::ForecastRequestData;
use Yahoo::Marketing::ForecastKeyword;

#use SOAP::Lite +trace => [qw/ debug method fault /];

my $section = 'sandbox';

sub test_get_forecast_for_keyword : Test(15) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ad_group = $self->common_test_data( 'test_ad_group' );

    my $ysm_ws = Yahoo::Marketing::ForecastService->new->parse_config( section => $section );

    my $forecast_request_data = Yahoo::Marketing::ForecastRequestData->new
        ->accountID( $ysm_ws->account )
        ->contentMatchMaxBid( '0.88' )
        ->marketID( 'US' )
        ->matchTypes( [qw(advanced_match content_match sponsored_search )] )
        ->sponsoredSearchMaxBid( '0.99' );

    my $result = $ysm_ws->getForecastForKeyword(
        keyword             => 'porche',
        adGroupID           => $ad_group->ID,
        forecastRequestData => $forecast_request_data,
    );

    ok( $result );

    my $forecast_response_detail = $result->forecastResponseDetail;

    ok( $forecast_response_detail );
    like( $forecast_response_detail->impressions, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_response_detail->maxBid, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_response_detail->missedClicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_response_detail->costPerClick, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_response_detail->clicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_response_detail->averagePosition, qr/^\d+(\.\d+)?$/, 'looks like a float number' );

    my $forecast_landscape = $result->forecastLandscape;
    ok( $forecast_landscape);
    like( $forecast_landscape->[0]->impressions, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_landscape->[0]->maxBid, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_landscape->[0]->missedClicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_landscape->[0]->costPerClick, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_landscape->[0]->clicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_landscape->[0]->averagePosition, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
}


sub test_get_forecast_for_keywords : Test(22) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ad_group = $self->common_test_data( 'test_ad_group' );

    my $ysm_ws = Yahoo::Marketing::ForecastService->new->parse_config( section => $section );

    my $forecast_request_data = Yahoo::Marketing::ForecastRequestData->new
        ->accountID( $ysm_ws->account )
        ->contentMatchMaxBid( '0.77' )
        ->marketID( 'US' )
        ->matchTypes( [qw(advanced_match content_match sponsored_search )] )
        ->sponsoredSearchMaxBid( '0.66' );

    my @forecast_keywords =
        (
            Yahoo::Marketing::ForecastKeyword->new
                  ->contentMatchMaxBid( '0.76' )
                  ->keyword( 'porche' )
                  ->sponsoredSearchMaxBid( '0.65' ),
            Yahoo::Marketing::ForecastKeyword->new
                  ->contentMatchMaxBid( '0.75' )
                  ->keyword( 'bmw' )
                  ->sponsoredSearchMaxBid( '0.64' ),
        );

    my $result = $ysm_ws->getForecastForKeywords(
        forecastKeywords    => \@forecast_keywords,
        adGroupID           => $ad_group->ID,
        forecastRequestData => $forecast_request_data,
    );

    ok( $result );

    my $customized_response_by_ad_group = $result->customizedResponseByAdGroup;
    ok( $customized_response_by_ad_group );
    like( $customized_response_by_ad_group->impressions, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $customized_response_by_ad_group->maxBid, qr/^NaN$|^\d+(\.\d+)?$/, 'looks like a float number (or NaN)' );  # allow NaN for the time being
    like( $customized_response_by_ad_group->missedClicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $customized_response_by_ad_group->costPerClick, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $customized_response_by_ad_group->clicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $customized_response_by_ad_group->averagePosition, qr/^\d+(\.\d+)?$/, 'looks like a float number' );

    my $default_response_by_ad_group = $result->defaultResponseByAdGroup;
    ok( $default_response_by_ad_group );
    like( $default_response_by_ad_group->impressions, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $default_response_by_ad_group->maxBid, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $default_response_by_ad_group->missedClicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $default_response_by_ad_group->costPerClick, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $default_response_by_ad_group->clicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $default_response_by_ad_group->averagePosition, qr/^\d+(\.\d+)?$/, 'looks like a float number' );

    my $landscape_by_ad_group = $result->landscapeByAdGroup;
    ok( $landscape_by_ad_group );
    like( $landscape_by_ad_group->[0]->impressions, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $landscape_by_ad_group->[0]->maxBid, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $landscape_by_ad_group->[0]->missedClicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $landscape_by_ad_group->[0]->costPerClick, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $landscape_by_ad_group->[0]->clicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $landscape_by_ad_group->[0]->averagePosition, qr/^\d+(\.\d+)?$/, 'looks like a float number' );

}


sub test_get_forecast_by_ad_group : Test(15) {
    my $self = shift;

    return 'not running post tests' unless $self->run_post_tests;

    my $ad_group = $self->common_test_data( 'test_ad_group' );

    my $ysm_ws = Yahoo::Marketing::ForecastService->new->parse_config( section => $section );

    my $forecast_request_data = Yahoo::Marketing::ForecastRequestData->new
        ->accountID( $ysm_ws->account )
        ->contentMatchMaxBid( '0.55' )
        ->marketID( 'US' )
        ->matchTypes( [qw(advanced_match content_match sponsored_search )] )
        ->sponsoredSearchMaxBid( '0.33' );

    my $result = $ysm_ws->getForecastByAdGroup(
        adGroupID           => $ad_group->ID,
        forecastRequestData => $forecast_request_data,
    );

    ok( $result );

    my $forecast_response_detail = $result->forecastResponseDetail;
    ok( $forecast_response_detail );
    like( $forecast_response_detail->impressions, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_response_detail->maxBid, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_response_detail->missedClicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_response_detail->costPerClick, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_response_detail->clicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_response_detail->averagePosition, qr/^\d+(\.\d+)?$/, 'looks like a float number' );

    my $forecast_landscape = $result->forecastLandscape;
    ok( $forecast_landscape);
    like( $forecast_landscape->[0]->impressions, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_landscape->[0]->maxBid, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_landscape->[0]->missedClicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_landscape->[0]->costPerClick, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_landscape->[0]->clicks, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
    like( $forecast_landscape->[0]->averagePosition, qr/^\d+(\.\d+)?$/, 'looks like a float number' );
}

sub startup_test_forecast_service : Test(startup) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    diag("preparing test data...");

    $self->common_test_data( 'test_campaign', $self->create_campaign ) unless defined $self->common_test_data( 'test_campaign' );
    $self->common_test_data( 'test_ad_group', $self->create_ad_group ) unless defined $self->common_test_data( 'test_ad_group' );
    $self->common_test_data( 'test_keyword', $self->create_keyword ) unless defined $self->common_test_data( 'test_keyword' );
};


sub shutdown_test_forecast_service : Test(shutdown) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    diag("cleaning test data...");
    $self->cleanup_keyword;
    $self->cleanup_ad_group;
    $self->cleanup_campaign;
};


1;

__END__

# getForecastForKeyword
# getForecastForKeywords
# getForecastByAdGroup

