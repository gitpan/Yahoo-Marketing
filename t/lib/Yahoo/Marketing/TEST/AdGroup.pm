package Yahoo::Marketing::TEST::AdGroup;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::AdGroup;

sub test_can_create_ad_group_and_set_all_fields : Test(18) {

    my $ad_group = Yahoo::Marketing::AdGroup->new
                                            ->ID( 'id' )
                                            ->accountID( 'account id' )
                                            ->adAutoOptimizationON( 'ad auto optimization on' )
                                            ->advancedMatchON( 'advanced match on' )
                                            ->campaignID( 'campaign id' )
                                            ->contentMatchMaxBid( 'content match max bid' )
                                            ->contentMatchON( 'content match on' )
                                            ->name( 'name' )
                                            ->sponsoredSearchMaxBid( 'sponsored search max bid' )
                                            ->sponsoredSearchON( 'sponsored search on' )
                                            ->status( 'status' )
                                            ->watchON( 'watch on' )
                                            ->contentMatchMaxBidTimestamp( 'content match max bid timestamp' )
                                            ->createTimestamp( 'create timestamp' )
                                            ->deleteTimestamp( 'delete timestamp' )
                                            ->lastUpdateTimestamp( 'last update timestamp' )
                                            ->sponsoredSearchMaxBidTimestamp( 'sponsored search max bid timestamp' )
                   ;

    ok( $ad_group );

    is( $ad_group->ID, 'id', 'can get id' );
    is( $ad_group->accountID, 'account id', 'can get account id' );
    is( $ad_group->adAutoOptimizationON, 'ad auto optimization on', 'can get ad auto optimization on' );
    is( $ad_group->advancedMatchON, 'advanced match on', 'can get advanced match on' );
    is( $ad_group->campaignID, 'campaign id', 'can get campaign id' );
    is( $ad_group->contentMatchMaxBid, 'content match max bid', 'can get content match max bid' );
    is( $ad_group->contentMatchON, 'content match on', 'can get content match on' );
    is( $ad_group->name, 'name', 'can get name' );
    is( $ad_group->sponsoredSearchMaxBid, 'sponsored search max bid', 'can get sponsored search max bid' );
    is( $ad_group->sponsoredSearchON, 'sponsored search on', 'can get sponsored search on' );
    is( $ad_group->status, 'status', 'can get status' );
    is( $ad_group->watchON, 'watch on', 'can get watch on' );
    is( $ad_group->contentMatchMaxBidTimestamp, 'content match max bid timestamp', 'can get content match max bid timestamp' );
    is( $ad_group->createTimestamp, 'create timestamp', 'can get create timestamp' );
    is( $ad_group->deleteTimestamp, 'delete timestamp', 'can get delete timestamp' );
    is( $ad_group->lastUpdateTimestamp, 'last update timestamp', 'can get last update timestamp' );
    is( $ad_group->sponsoredSearchMaxBidTimestamp, 'sponsored search max bid timestamp', 'can get sponsored search max bid timestamp' );

};



1;

