package Yahoo::Marketing::Test::GeoTargetProbabilitySet;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::GeoTargetProbabilitySet;

sub test_can_create_geo_target_probability_set_and_set_all_fields : Test(3) {

    my $geo_target_probability_set = Yahoo::Marketing::GeoTargetProbabilitySet->new
                                                                              ->geoString( 'geo string' )
                                                                              ->geoTargetProbability( 'geo target probability' )
                   ;

    ok( $geo_target_probability_set );

    is( $geo_target_probability_set->geoString, 'geo string', 'can get geo string' );
    is( $geo_target_probability_set->geoTargetProbability, 'geo target probability', 'can get geo target probability' );

};



1;

