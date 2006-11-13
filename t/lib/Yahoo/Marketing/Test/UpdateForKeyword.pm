package Yahoo::Marketing::Test::UpdateForKeyword;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::UpdateForKeyword;

sub test_can_create_update_for_keyword_and_set_all_fields : Test(11) {

    my $update_for_keyword = Yahoo::Marketing::UpdateForKeyword->new
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

    ok( $update_for_keyword );

    is( $update_for_keyword->ID, 'id', 'can get id' );
    is( $update_for_keyword->accountID, 'account id', 'can get account id' );
    is( $update_for_keyword->alternateText, 'alternate text', 'can get alternate text' );
    is( $update_for_keyword->canonicalSearchText, 'canonical search text', 'can get canonical search text' );
    is( $update_for_keyword->editorialStatus, 'editorial status', 'can get editorial status' );
    is( $update_for_keyword->phraseSearchText, 'phrase search text', 'can get phrase search text' );
    is( $update_for_keyword->text, 'text', 'can get text' );
    is( $update_for_keyword->url, 'url', 'can get url' );
    is( $update_for_keyword->createTimestamp, 'create timestamp', 'can get create timestamp' );
    is( $update_for_keyword->lastUpdateTimestamp, 'last update timestamp', 'can get last update timestamp' );

};



1;

