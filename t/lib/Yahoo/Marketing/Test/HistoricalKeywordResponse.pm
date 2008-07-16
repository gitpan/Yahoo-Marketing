package Yahoo::Marketing::Test::HistoricalKeywordResponse;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::HistoricalKeywordResponse;

sub test_can_create_historical_keyword_response_and_set_all_fields : Test(4) {

    my $historical_keyword_response = Yahoo::Marketing::HistoricalKeywordResponse->new
                                                                                 ->historicalData( 'historical data' )
                                                                                 ->keyword( 'keyword' )
                                                                                 ->matchTypes( 'match types' )
                   ;

    ok( $historical_keyword_response );

    is( $historical_keyword_response->historicalData, 'historical data', 'can get historical data' );
    is( $historical_keyword_response->keyword, 'keyword', 'can get keyword' );
    is( $historical_keyword_response->matchTypes, 'match types', 'can get match types' );

};



1;

