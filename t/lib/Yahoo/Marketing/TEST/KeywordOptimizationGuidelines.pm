package Yahoo::Marketing::TEST::KeywordOptimizationGuidelines;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::KeywordOptimizationGuidelines;

sub test_can_create_keyword_optimization_guidelines_and_set_all_fields : Test(7) {

    my $keyword_optimization_guidelines = Yahoo::Marketing::KeywordOptimizationGuidelines->new
                                                                                         ->accountID( 'account id' )
                                                                                         ->adGroupID( 'ad group id' )
                                                                                         ->keywordID( 'keyword id' )
                                                                                         ->sponsoredSearchMaxBid( 'sponsored search max bid' )
                                                                                         ->createTimestamp( 'create timestamp' )
                                                                                         ->lastUpdateTimestamp( 'last update timestamp' )
                   ;

    ok( $keyword_optimization_guidelines );

    is( $keyword_optimization_guidelines->accountID, 'account id', 'can get account id' );
    is( $keyword_optimization_guidelines->adGroupID, 'ad group id', 'can get ad group id' );
    is( $keyword_optimization_guidelines->keywordID, 'keyword id', 'can get keyword id' );
    is( $keyword_optimization_guidelines->sponsoredSearchMaxBid, 'sponsored search max bid', 'can get sponsored search max bid' );
    is( $keyword_optimization_guidelines->createTimestamp, 'create timestamp', 'can get create timestamp' );
    is( $keyword_optimization_guidelines->lastUpdateTimestamp, 'last update timestamp', 'can get last update timestamp' );

};



1;

