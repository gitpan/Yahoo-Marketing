package Yahoo::Marketing::Test::GeographicalTargetingService;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997)

use strict; use warnings;

use base qw/ Test::Class Yahoo::Marketing::Test::PostTest /;
use Test::More;

use Yahoo::Marketing::GeographicalTargetingService;
use Data::Dumper;

# use SOAP::Lite +trace => [qw/ debug method fault /];

sub SKIP_CLASS {
    my $self = shift;
    # 'not running post tests' is a true value
    return 'not running post tests' unless $self->run_post_tests;
    return;
}


sub test_geo_targeting_service : Test(22) {
    my ( $self ) = @_;

    my $ysm_ws = Yahoo::Marketing::GeographicalTargetingService->new->parse_config( section => $self->section );

    # test getGeoTargetsByString
    my @probilities = $ysm_ws->getGeoTargetsByString( geoString => 'california' );
    ok( @probilities, 'can call getGeoTargetsByString' );
    my $calif = $probilities[0];

    ok( $calif->probability, 'can get probability' );
    is( $calif->geotarget->name, 'California', 'name matches' );
    is( $calif->geotarget->type, 'State', 'type matches' );

    my $woeid = $calif->geotarget->ID; # 2347563

    # test getGeoTargetsByStrings
    my @probility_sets = $ysm_ws->getGeoTargetsByStrings( geoStrings => ['california'] );
    ok( @probility_sets, 'can call getGeoTargetsByStrings' );
    my $probility = $probility_sets[0];
    is( $probility->geoString, 'california', 'geoString matches' );
    is( $probility->geoTargetProbability->[0]->geotarget->ID, '2347563', 'ID matches' );

    # test getAncestorGeoTargets
    my @values = $ysm_ws->getAncestorGeoTargets( geoTargetWOEID => $woeid );
    ok( @values, 'can call getAncestorGeoTargets' );
    is( $values[0]->name, 'United States', 'name matches' );
    is( $values[0]->type, 'Country', 'type matches' );

    my $us_woeid = $values[0]->ID; # 23424977

    # test getGeoTarget
    my $value = $ysm_ws->getGeoTarget( geoTargetWOEID => $woeid );
    ok( $value, 'can call getGeoTarget' );
    is( $value->ID, '2347563', 'ID matches' );

    # test getGeoTargets
    @values = $ysm_ws->getGeoTargets( geoTargetWOEIDs => [$woeid] );
    ok( @values, 'can call getGeoTarget' );
    is( $values[0]->ID, '2347563', 'ID matches' );

    # test getGeoTargetsByStringByCountry
    @probilities = $ysm_ws->getGeoTargetsByStringByCountry( geoString => 'california', countryWOEID => $us_woeid );
    ok( @probilities, 'can call getGeoTargetsByStringByCountry' );
    is( $probilities[0]->geotarget->name, 'California', 'name matches' );

    # test getTargetableGeoLevels
    my @types = $ysm_ws->getTargetableGeoLevels();
    ok( @types, 'can call getTargetableGeoLevels' );
    is( $types[0], 'Country', 'type matches' );

    # test getGeoTargetsByParentByLevel
    @values = $ysm_ws->getGeoTargetsByParentByLevel( parentWOEID => $woeid, geoLevel => 'MarketingArea', startElement => 0, numElements => 5 );
    ok( @values, 'can call getGeoTargetsByParentByLevel' );
    like( $values[0]->description, qr/DMA/, 'description matches' );

    # test getZipGeoTargetsWithinRadius
    @probilities = $ysm_ws->getGeoTargetsByString( geoString => 'burbank' );
    @values = $ysm_ws->getGeoTargetsByParentByLevel( parentWOEID => $probilities[0]->geotarget->ID, geoLevel => 'Zip', startElement => 0, numElements => 5 );
    @values = $ysm_ws->getZipGeoTargetsWithinRadius( radius => 200, distanceUnits => 'Miles', zipWOEID => $values[0]->ID, startElement => 0, numElements => 5 );
    ok( @values, 'can call getZipGeoTargetsWithinRadius' );
    is( $values[0]->type, 'Zip', 'type matches' );

}


1;

