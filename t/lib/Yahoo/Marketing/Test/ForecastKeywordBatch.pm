package Yahoo::Marketing::Test::ForecastKeywordBatch;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::ForecastKeywordBatch;

sub test_can_create_forecast_keyword_batch_and_set_all_fields : Test(6) {

    my $forecast_keyword_batch = Yahoo::Marketing::ForecastKeywordBatch->new
	                                                              ->adGroupID( 'ad group id' )
                                                                      ->contentMatchMaxBid( 'content match max bid' )
                                                                      ->keyword( 'keyword' )
                                                                      ->matchTypes( 'match types' )
                                                                      ->sponsoredSearchMaxBid( 'sponsored search max bid' );

    ok( $forecast_keyword_batch );

    is( $forecast_keyword_batch->adGroupID, 'ad group id', 'can get ad group id' );
    is( $forecast_keyword_batch->contentMatchMaxBid, 'content match max bid', 'can get content match max bid' );
    is( $forecast_keyword_batch->keyword, 'keyword', 'can get keyword' );
    is( $forecast_keyword_batch->matchTypes, 'match types', 'can get match types' );
    is( $forecast_keyword_batch->sponsoredSearchMaxBid, 'sponsored search max bid', 'can get sponsored search max bid' );

};



1;

