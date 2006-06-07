package Yahoo::Marketing::TEST::ForecastKeyword;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::ForecastKeyword;

sub test_can_create_forecast_keyword_and_set_all_fields : Test(5) {

    my $forecast_keyword = Yahoo::Marketing::ForecastKeyword->new
                                                            ->contentMatchMaxBid( 'content match max bid' )
                                                            ->keyword( 'keyword' )
                                                            ->matchType( 'match type' )
                                                            ->sponsoredSearchMaxBid( 'sponsored search max bid' )
                   ;

    ok( $forecast_keyword );

    is( $forecast_keyword->contentMatchMaxBid, 'content match max bid', 'can get content match max bid' );
    is( $forecast_keyword->keyword, 'keyword', 'can get keyword' );
    is( $forecast_keyword->matchType, 'match type', 'can get match type' );
    is( $forecast_keyword->sponsoredSearchMaxBid, 'sponsored search max bid', 'can get sponsored search max bid' );

};



1;

