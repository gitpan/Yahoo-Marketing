package Yahoo::Marketing::Test::GeoTargetProbability;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::GeoTargetProbability;

sub test_can_create_geo_target_probability_and_set_all_fields : Test(3) {

    my $geo_target_probability = Yahoo::Marketing::GeoTargetProbability->new
                                                                       ->geotarget( 'geotarget' )
                                                                       ->probability( 'probability' )
                   ;

    ok( $geo_target_probability );

    is( $geo_target_probability->geotarget, 'geotarget', 'can get geotarget' );
    is( $geo_target_probability->probability, 'probability', 'can get probability' );

};



1;

