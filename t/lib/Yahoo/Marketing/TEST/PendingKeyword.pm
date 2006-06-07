package Yahoo::Marketing::TEST::PendingKeyword;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::PendingKeyword;

sub test_can_create_pending_keyword_and_set_all_fields : Test(11) {

    my $pending_keyword = Yahoo::Marketing::PendingKeyword->new
                                                          ->ID( 'id' )
                                                          ->accountID( 'account id' )
                                                          ->alternateText( 'alternate text' )
                                                          ->canonicalSearchText( 'canonical search text' )
                                                          ->editorialStatus( 'editorial status' )
                                                          ->phraseSearchText( 'phrase search text' )
                                                          ->text( 'text' )
                                                          ->url( 'url' )
                                                          ->createTimestamp( 'create timestamp' )
                                                          ->lastUpdateTimestamp( 'last update timestamp' )
                   ;

    ok( $pending_keyword );

    is( $pending_keyword->ID, 'id', 'can get id' );
    is( $pending_keyword->accountID, 'account id', 'can get account id' );
    is( $pending_keyword->alternateText, 'alternate text', 'can get alternate text' );
    is( $pending_keyword->canonicalSearchText, 'canonical search text', 'can get canonical search text' );
    is( $pending_keyword->editorialStatus, 'editorial status', 'can get editorial status' );
    is( $pending_keyword->phraseSearchText, 'phrase search text', 'can get phrase search text' );
    is( $pending_keyword->text, 'text', 'can get text' );
    is( $pending_keyword->url, 'url', 'can get url' );
    is( $pending_keyword->createTimestamp, 'create timestamp', 'can get create timestamp' );
    is( $pending_keyword->lastUpdateTimestamp, 'last update timestamp', 'can get last update timestamp' );

};



1;

