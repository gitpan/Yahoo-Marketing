package Yahoo::Marketing::Test::UpdateForAd;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::UpdateForAd;

sub test_can_create_update_for_ad_and_set_all_fields : Test(11) {

    my $update_for_ad = Yahoo::Marketing::UpdateForAd->new
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

    ok( $update_for_ad );

    is( $update_for_ad->ID, 'id', 'can get id' );
    is( $update_for_ad->accountID, 'account id', 'can get account id' );
    is( $update_for_ad->description, 'description', 'can get description' );
    is( $update_for_ad->displayUrl, 'display url', 'can get display url' );
    is( $update_for_ad->editorialStatus, 'editorial status', 'can get editorial status' );
    is( $update_for_ad->shortDescription, 'short description', 'can get short description' );
    is( $update_for_ad->title, 'title', 'can get title' );
    is( $update_for_ad->url, 'url', 'can get url' );
    is( $update_for_ad->createTimestamp, 'create timestamp', 'can get create timestamp' );
    is( $update_for_ad->lastUpdateTimestamp, 'last update timestamp', 'can get last update timestamp' );

};



1;

