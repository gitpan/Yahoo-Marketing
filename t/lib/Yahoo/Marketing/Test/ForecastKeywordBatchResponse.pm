package Yahoo::Marketing::Test::ForecastKeywordBatchResponse;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::ForecastKeywordBatchResponse;

sub test_can_create_forecast_keyword_batch_response_and_set_all_fields : Test(9) {

    my $forecast_keyword_batch_response = Yahoo::Marketing::ForecastKeywordBatchResponse->new
                                                                          ->canonKeyword( 'canon keyword' )
                                                                          ->errors( 'errors' )
                                                                          ->forecastLandscape( 'forecast landscape' )
                                                                          ->forecastResponseDetail( 'forecast response detail' )
                                                                          ->keyword( 'keyword' )
                                                                          ->matchTypes( 'match types' )
                                                                          ->operationSucceeded( 'operation succeeded' )
                                                                          ->warnings( 'warnings' )
                   ;

    ok( $forecast_keyword_batch_response );

    is( $forecast_keyword_batch_response->canonKeyword, 'canon keyword', 'can get canon keyword' );
    is( $forecast_keyword_batch_response->errors, 'errors', 'can get errors' );
    is( $forecast_keyword_batch_response->forecastLandscape, 'forecast landscape', 'can get forecast landscape' );
    is( $forecast_keyword_batch_response->forecastResponseDetail, 'forecast response detail', 'can get forecast response detail' );
    is( $forecast_keyword_batch_response->keyword, 'keyword', 'can get keyword' );
    is( $forecast_keyword_batch_response->matchTypes, 'match types', 'can get match types' );
    is( $forecast_keyword_batch_response->operationSucceeded, 'operation succeeded', 'can get operation succeeded' );
    is( $forecast_keyword_batch_response->warnings, 'warnings', 'can get warnings' );

};



1;

