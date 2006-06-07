package Yahoo::Marketing::TEST::Campaign;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::Campaign;

sub test_can_create_campaign_and_set_all_fields : Test(16) {

    my $campaign = Yahoo::Marketing::Campaign->new
                                             ->ID( 'id' )
                                             ->accountID( 'account id' )
                                             ->advancedMatchON( 'advanced match on' )
                                             ->campaignOptimizationON( 'campaign optimization on' )
                                             ->contentMatchON( 'content match on' )
                                             ->description( 'description' )
                                             ->endDate( 'end date' )
                                             ->name( 'name' )
                                             ->sponsoredSearchON( 'sponsored search on' )
                                             ->startDate( 'start date' )
                                             ->status( 'status' )
                                             ->watchON( 'watch on' )
                                             ->createTimestamp( 'create timestamp' )
                                             ->deleteTimestamp( 'delete timestamp' )
                                             ->lastUpdateTimestamp( 'last update timestamp' )
                   ;

    ok( $campaign );

    is( $campaign->ID, 'id', 'can get id' );
    is( $campaign->accountID, 'account id', 'can get account id' );
    is( $campaign->advancedMatchON, 'advanced match on', 'can get advanced match on' );
    is( $campaign->campaignOptimizationON, 'campaign optimization on', 'can get campaign optimization on' );
    is( $campaign->contentMatchON, 'content match on', 'can get content match on' );
    is( $campaign->description, 'description', 'can get description' );
    is( $campaign->endDate, 'end date', 'can get end date' );
    is( $campaign->name, 'name', 'can get name' );
    is( $campaign->sponsoredSearchON, 'sponsored search on', 'can get sponsored search on' );
    is( $campaign->startDate, 'start date', 'can get start date' );
    is( $campaign->status, 'status', 'can get status' );
    is( $campaign->watchON, 'watch on', 'can get watch on' );
    is( $campaign->createTimestamp, 'create timestamp', 'can get create timestamp' );
    is( $campaign->deleteTimestamp, 'delete timestamp', 'can get delete timestamp' );
    is( $campaign->lastUpdateTimestamp, 'last update timestamp', 'can get last update timestamp' );

};



1;

