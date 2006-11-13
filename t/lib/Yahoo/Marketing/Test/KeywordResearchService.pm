package Yahoo::Marketing::Test::KeywordResearchService;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/ Yahoo::Marketing::Test::PostTest /;
use Test::More;

use Yahoo::Marketing::KeywordResearchService;
use Yahoo::Marketing::PageRelatedKeywordRequestType;
use Yahoo::Marketing::RelatedKeywordRequestType;
use Yahoo::Marketing::RangeDefinitionRequestType;

#use SOAP::Lite +trace => [qw/ debug method fault /];

my $section = 'sandbox';

sub test_get_page_related_keywords : Test(5) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $page_related_keyword_request_type = Yahoo::Marketing::PageRelatedKeywordRequestType->new
        ->excludedKeywords( [ 'autos', 'music' ] )
        ->market( 'US' )
        ->maxKeywords( '3' )
        ->excludedPhraseFilters( [ 'xbox' ] )
        ->negativeKeywords( [ 'people' ] )
        ->positiveKeywords( [ 'gadget' ] )
        ->requiredPhraseFilters( [ 'laptop' ])
        ->URL( 'http://www.yahoo.com' );

    my $ysm_ws = Yahoo::Marketing::KeywordResearchService->new->parse_config( section => $section );

    my $result = $ysm_ws->getPageRelatedKeywords(
        pageRelatedKeywordRequest => $page_related_keyword_request_type,
    );

    ok( $result );
    is( scalar @{$result->relatedKeywords}, 3 );
    foreach my $related_keyword_type ( @{$result->relatedKeywords} ) {
        like( $related_keyword_type->common, qr/laptop/ );
    }
};

sub test_get_related_keywords : Test(5) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $related_keyword_request_type = Yahoo::Marketing::RelatedKeywordRequestType->new
        ->excludedKeywords( [ 'autos', 'music' ] )
        ->excludedPhraseFilters( [ 'xbox' ] )
        ->market( 'US' )
        ->maxKeywords( '3' )
        ->negativeKeywords( [ 'people' ] )
        ->positiveKeywords( [ 'gadget' ] )
        ->requiredPhraseFilters( [ 'laptop' ]);

    my $ysm_ws = Yahoo::Marketing::KeywordResearchService->new->parse_config( section => $section );

    my $result = $ysm_ws->getRelatedKeywords(
        relatedKeywordRequest => $related_keyword_request_type,
    );

    ok( $result );
    is( scalar @{$result->relatedKeywords}, 3 );
    foreach my $related_keyword_type ( @{$result->relatedKeywords} ) {
        like( $related_keyword_type->common, qr/laptop/ );
    }
};

sub test_get_range_definitions : Test(3) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $range_definition_request_type = Yahoo::Marketing::RangeDefinitionRequestType->new
        ->market( 'US' )
        ->rangeName( [ 'Searches' ] );

    my $ysm_ws = Yahoo::Marketing::KeywordResearchService->new->parse_config( section => $section );

    my $result = $ysm_ws->getRangeDefinitions(
        rangeDefinitionRequest => $range_definition_request_type,
    );

    ok( $result );

    is( $result->rangeDefinition->[0]->market, 'US' );
    is( $result->rangeDefinition->[0]->rangeName, 'Searches' );
}

1;

__END__

# getPageRelatedKeywords
# getRangeDefinitions
# getRelatedKeywords
