package Yahoo::Marketing::Test::HistoricalKeyword;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::HistoricalKeyword;

sub test_can_create_historical_keyword : Test(3) {

    my $historical_keyword = Yahoo::Marketing::HistoricalKeyword->new
                                                                ->keyword( 'keyword' )
                                                                ->matchTypes( 'match types' )
                   ;

    ok( $historical_keyword );

    is( $historical_keyword->keyword, 'keyword', 'can get keyword' );
    is( $historical_keyword->matchTypes, 'match types', 'can get match types' );

};



1;

