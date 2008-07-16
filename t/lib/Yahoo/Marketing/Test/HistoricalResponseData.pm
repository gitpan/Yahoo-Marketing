package Yahoo::Marketing::Test::HistoricalResponseData;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::HistoricalResponseData;

sub test_can_create_historical_response_data_and_set_all_fields : Test(6) {

    my $historical_response_data = Yahoo::Marketing::HistoricalResponseData->new
                                                                        ->avgSearches( 'avg searches' )
                                                                        ->competitiveRating( 'competitive rating' )
                                                                        ->errors( 'errors' )
                                                                        ->monthYear( 'month year' )
                                                                        ->operationSucceeded( 'operation succeeded' )
                   ;

    ok( $historical_response_data );

    is( $historical_response_data->avgSearches, 'avg searches', 'can get avg searches' );
    is( $historical_response_data->competitiveRating, 'competitive rating', 'can get competitive rating' );
    is( $historical_response_data->errors, 'errors', 'errors' );
    is( $historical_response_data->monthYear, 'month year', 'can get month year' );
    is( $historical_response_data->operationSucceeded, 'operation succeeded', 'can get operation succeeded' );

};



1;

