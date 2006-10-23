package Yahoo::Marketing::TEST::ExcludedWord;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::ExcludedWord;

sub test_can_create_excluded_word_and_set_all_fields : Test(6) {

    my $excluded_word = Yahoo::Marketing::ExcludedWord->new
                                                      ->accountID( 'account id' )
                                                      ->adGroupID( 'ad group id' )
                                                      ->text( 'text' )
                                                      ->createTimestamp( 'create timestamp' )
                                                      ->deleteTimestamp( 'delete timestamp' )
                   ;

    ok( $excluded_word );

    is( $excluded_word->accountID, 'account id', 'can get account id' );
    is( $excluded_word->adGroupID, 'ad group id', 'can get ad group id' );
    is( $excluded_word->text, 'text', 'can get text' );
    is( $excluded_word->createTimestamp, 'create timestamp', 'can get create timestamp' );
    is( $excluded_word->deleteTimestamp, 'delete timestamp', 'can get delete timestamp' );

};



1;

