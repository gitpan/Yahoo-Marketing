package Yahoo::Marketing::Test::Account;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::Account;

sub test_can_create_account_and_set_all_fields : Test(16) {

    my $account = Yahoo::Marketing::Account->new
                                           ->ID( 'id' )
                                           ->advancedMatchON( 'advanced match on' )
                                           ->businessTypeCode( 'business type code' )
                                           ->contentMatchON( 'content match on' )
                                           ->displayURL( 'display url' )
                                           ->marketID( 'market id' )
                                           ->masterAccountID( 'master account id' )
                                           ->name( 'name' )
                                           ->nameFurigana( 'name furigana' )
                                           ->personalID( 'personal id' )
                                           ->sitePassword( 'site password' )
                                           ->siteUserName( 'site user name' )
                                           ->sponsoredSearchON( 'sponsored search on' )
                                           ->vatCode( 'vat code' )
                                           ->websiteURL( 'website url' )
                   ;

    ok( $account );

    is( $account->ID, 'id', 'can get id' );
    is( $account->advancedMatchON, 'advanced match on', 'can get advanced match on' );
    is( $account->businessTypeCode, 'business type code', 'can get business type code' );
    is( $account->contentMatchON, 'content match on', 'can get content match on' );
    is( $account->displayURL, 'display url', 'can get display url' );
    is( $account->marketID, 'market id', 'can get market id' );
    is( $account->masterAccountID, 'master account id', 'can get master account id' );
    is( $account->name, 'name', 'can get name' );
    is( $account->nameFurigana, 'name furigana', 'can get name furigana' );
    is( $account->personalID, 'personal id', 'can get personal id' );
    is( $account->sitePassword, 'site password', 'can get site password' );
    is( $account->siteUserName, 'site user name', 'can get site user name' );
    is( $account->sponsoredSearchON, 'sponsored search on', 'can get sponsored search on' );
    is( $account->vatCode, 'vat code', 'can get vat code' );
    is( $account->websiteURL, 'website url', 'can get website url' );

};



1;

