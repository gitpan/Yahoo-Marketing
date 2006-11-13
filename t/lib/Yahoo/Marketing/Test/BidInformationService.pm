package Yahoo::Marketing::Test::BidInformationService;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/ Yahoo::Marketing::Test::PostTest /;
use Test::More;

use Yahoo::Marketing::BidInformation;
use Yahoo::Marketing::BidInformationService;

#use SOAP::Lite +trace => [qw/ debug method fault /];

my $section = 'sandbox';

sub test_get_bids_for_best_rank : Test(3) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ad_group = $self->common_test_data( 'test_ad_group' );

    my $ysm_ws = Yahoo::Marketing::BidInformationService->new->parse_config( section => $section );

    my $bid_information = $ysm_ws->getBidsForBestRank(
        adGroupID => $ad_group->ID,
        keyword   => 'porsche',
    );

    ok( $bid_information );
    like( $bid_information->bid, qr/^\d+(\.\d+)?$/, 'bid looks like float' );
    like( $bid_information->cutOffBid, qr/^\d+(\.\d+)?$/, 'cutOffBid looks like float' );
};


sub startup_test_bid_information_service : Test(startup) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    diag("preparing test data...");

    $self->common_test_data( 'test_campaign', $self->create_campaign ) unless defined $self->common_test_data( 'test_campaign' );
    $self->common_test_data( 'test_ad_group', $self->create_ad_group ) unless defined $self->common_test_data( 'test_ad_group' );
};


sub shutdown_test_bid_information_service : Test(shutdown) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    diag("cleaning test data...");
    $self->cleanup_ad_group;
    $self->cleanup_campaign;
};

1;

__END__

# getBidsForBestRank
