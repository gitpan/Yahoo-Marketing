package Yahoo::Marketing::TEST::ForecastKeywordResponse;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::ForecastKeywordResponse;

sub test_can_create_forecast_keyword_response_and_set_all_fields : Test(4) {

    my $forecast_keyword_response = Yahoo::Marketing::ForecastKeywordResponse->new
                                                                             ->customizedResponseByAdGroup( 'customized response by ad group' )
                                                                             ->defaultResponseByAdGroup( 'default response by ad group' )
                                                                             ->landscapeByAdGroup( 'landscape by ad group' )
                   ;

    ok( $forecast_keyword_response );

    is( $forecast_keyword_response->customizedResponseByAdGroup, 'customized response by ad group', 'can get customized response by ad group' );
    is( $forecast_keyword_response->defaultResponseByAdGroup, 'default response by ad group', 'can get default response by ad group' );
    is( $forecast_keyword_response->landscapeByAdGroup, 'landscape by ad group', 'can get landscape by ad group' );

};



1;

