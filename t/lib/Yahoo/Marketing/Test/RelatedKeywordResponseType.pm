package Yahoo::Marketing::Test::RelatedKeywordResponseType;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::RelatedKeywordResponseType;

sub test_can_create_related_keyword_response_type_and_set_all_fields : Test(4) {

    my $related_keyword_response_type = Yahoo::Marketing::RelatedKeywordResponseType->new
                                                                                    ->notes( 'notes' )
                                                                                    ->relatedKeywords( 'related keywords' )
                                                                                    ->responseStatus( 'response status' )
                   ;

    ok( $related_keyword_response_type );

    is( $related_keyword_response_type->notes, 'notes', 'can get notes' );
    is( $related_keyword_response_type->relatedKeywords, 'related keywords', 'can get related keywords' );
    is( $related_keyword_response_type->responseStatus, 'response status', 'can get response status' );

};



1;

