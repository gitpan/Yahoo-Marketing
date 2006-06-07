package Yahoo::Marketing::TEST::PendingAd;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::PendingAd;

sub test_can_create_pending_ad_and_set_all_fields : Test(11) {

    my $pending_ad = Yahoo::Marketing::PendingAd->new
                                                ->ID( 'id' )
                                                ->accountID( 'account id' )
                                                ->description( 'description' )
                                                ->displayUrl( 'display url' )
                                                ->editorialStatus( 'editorial status' )
                                                ->shortDescription( 'short description' )
                                                ->title( 'title' )
                                                ->url( 'url' )
                                                ->createTimestamp( 'create timestamp' )
                                                ->lastUpdateTimestamp( 'last update timestamp' )
                   ;

    ok( $pending_ad );

    is( $pending_ad->ID, 'id', 'can get id' );
    is( $pending_ad->accountID, 'account id', 'can get account id' );
    is( $pending_ad->description, 'description', 'can get description' );
    is( $pending_ad->displayUrl, 'display url', 'can get display url' );
    is( $pending_ad->editorialStatus, 'editorial status', 'can get editorial status' );
    is( $pending_ad->shortDescription, 'short description', 'can get short description' );
    is( $pending_ad->title, 'title', 'can get title' );
    is( $pending_ad->url, 'url', 'can get url' );
    is( $pending_ad->createTimestamp, 'create timestamp', 'can get create timestamp' );
    is( $pending_ad->lastUpdateTimestamp, 'last update timestamp', 'can get last update timestamp' );

};



1;

