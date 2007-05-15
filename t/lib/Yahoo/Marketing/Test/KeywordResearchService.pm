package Yahoo::Marketing::Test::KeywordResearchService;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/ Yahoo::Marketing::Test::PostTest /;
use Test::More;

use Yahoo::Marketing::KeywordResearchService;
use Yahoo::Marketing::KeywordInfoRequestType;
use Yahoo::Marketing::RelatedKeywordRequestType;
use Yahoo::Marketing::RangeDefinitionRequestType;
use Yahoo::Marketing::PageRelatedKeywordRequestType;

#use SOAP::Lite +trace => [qw/ debug method fault /];

my $section = 'sandbox';

sub test_get_common_keywords : Test(5) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::KeywordResearchService->new->parse_config( section => $section );

    my $result = $ysm_ws->getCommonKeywords(
        getCommonKeywordsRequest 
            => Yahoo::Marketing::KeywordInfoRequestType->new
                                                       ->keywords( [ qw/lions tigers bears/ ] )
                                                       ->market( 'US' ) 

    );

    ok( $result );

    is( $result->responseStatus->status, 'Success', 'request was succesful' );
    foreach my $keyword_response ( @{ $result->keywords } ){
        like( $keyword_response->canonical , qr/^(lion|tiger|bear)$/, 'lions and tigers and bears, oh my!' );
    }
}

sub test_get_canonical_keywords : Test(5) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::KeywordResearchService->new->parse_config( section => $section );

    my $result = $ysm_ws->getCanonicalKeywords(
        getCanonicalKeywordsRequest
            => Yahoo::Marketing::KeywordInfoRequestType->new
                                                       ->keywords( [ qw/lions tigers bears/ ] )
                                                       ->market( 'US' ) 
    );

    ok( $result );

    is( $result->responseStatus->status, 'Success', 'request was succesful' );
    foreach my $keyword_response ( @{ $result->keywords } ){
        like( $keyword_response->canonical , qr/^(lion|tiger|bear)$/, 'lions and tigers and bears, oh my!' );
    }
}


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
}

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
}

sub test_get_related_keywords_works_for_no_results : Test(3) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $related_keyword_request_type = Yahoo::Marketing::RelatedKeywordRequestType->new
        ->market( 'US' )
        ->maxKeywords( '3' )
        ->positiveKeywords( [ 'pandas bears llamas' ] )
    ;

    my $ysm_ws = Yahoo::Marketing::KeywordResearchService->new->parse_config( section => $section );

    my $result = $ysm_ws->getRelatedKeywords(
        relatedKeywordRequest => $related_keyword_request_type,
    );

    ok( $result );
    ok( not $result->relatedKeywords );
}

sub test_get_range_definitions : Test(3) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $range_definition_request_type = Yahoo::Marketing::RangeDefinitionRequestType->new
        ->market( 'US' )
        ->rangeName( [ 'Searches' ] )
    ;

    my $ysm_ws = Yahoo::Marketing::KeywordResearchService->new->parse_config( section => $section );

    my $result = $ysm_ws->getRangeDefinitions(
        rangeDefinitionRequest => $range_definition_request_type,
    );

    ok( $result );

    is( $result->rangeDefinition->[0]->market, 'US' );
    is( $result->rangeDefinition->[0]->rangeName, 'Searches' );
}

=cut

1;

__END__

# getPageRelatedKeywords
# getRangeDefinitions
# getRelatedKeywords
# getCanonicalKeywords
# getCommonKeywords
