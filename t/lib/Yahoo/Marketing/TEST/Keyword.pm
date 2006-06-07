package Yahoo::Marketing::TEST::Keyword;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::Keyword;

sub test_can_create_keyword_and_set_all_fields : Test(19) {

    my $keyword = Yahoo::Marketing::Keyword->new
                                           ->ID( 'id' )
                                           ->accountID( 'account id' )
                                           ->adGroupID( 'ad group id' )
                                           ->advancedMatchON( 'advanced match on' )
                                           ->alternateText( 'alternate text' )
                                           ->canonicalSearchText( 'canonical search text' )
                                           ->editorialStatus( 'editorial status' )
                                           ->pending( 'pending' )
                                           ->phraseSearchText( 'phrase search text' )
                                           ->sponsoredSearchMaxBid( 'sponsored search max bid' )
                                           ->status( 'status' )
                                           ->text( 'text' )
                                           ->url( 'url' )
                                           ->watchON( 'watch on' )
                                           ->createTimestamp( 'create timestamp' )
                                           ->deleteTimestamp( 'delete timestamp' )
                                           ->lastUpdateTimestamp( 'last update timestamp' )
                                           ->sponsoredSearchMaxBidTimestamp( 'sponsored search max bid timestamp' )
                   ;

    ok( $keyword );

    is( $keyword->ID, 'id', 'can get id' );
    is( $keyword->accountID, 'account id', 'can get account id' );
    is( $keyword->adGroupID, 'ad group id', 'can get ad group id' );
    is( $keyword->advancedMatchON, 'advanced match on', 'can get advanced match on' );
    is( $keyword->alternateText, 'alternate text', 'can get alternate text' );
    is( $keyword->canonicalSearchText, 'canonical search text', 'can get canonical search text' );
    is( $keyword->editorialStatus, 'editorial status', 'can get editorial status' );
    is( $keyword->pending, 'pending', 'can get pending' );
    is( $keyword->phraseSearchText, 'phrase search text', 'can get phrase search text' );
    is( $keyword->sponsoredSearchMaxBid, 'sponsored search max bid', 'can get sponsored search max bid' );
    is( $keyword->status, 'status', 'can get status' );
    is( $keyword->text, 'text', 'can get text' );
    is( $keyword->url, 'url', 'can get url' );
    is( $keyword->watchON, 'watch on', 'can get watch on' );
    is( $keyword->createTimestamp, 'create timestamp', 'can get create timestamp' );
    is( $keyword->deleteTimestamp, 'delete timestamp', 'can get delete timestamp' );
    is( $keyword->lastUpdateTimestamp, 'last update timestamp', 'can get last update timestamp' );
    is( $keyword->sponsoredSearchMaxBidTimestamp, 'sponsored search max bid timestamp', 'can get sponsored search max bid timestamp' );

};



1;

