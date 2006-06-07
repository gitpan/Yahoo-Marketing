package Yahoo::Marketing::TEST::AdService;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;
use base qw/ Test::Class Yahoo::Marketing::TEST::PostTest /;
use Test::More;

use Yahoo::Marketing::Ad;
use Yahoo::Marketing::AdService;
use Yahoo::Marketing::AccountService;
use Data::Dumper;

#use SOAP::Lite +trace => [qw/ debug method fault /];

my $section = 'sandbox';

sub startup_test_ad_service : Test(startup) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    diag("preparing test data...");

    $self->common_test_data( 'test_campaign', $self->create_campaign );
    $self->common_test_data( 'test_ad_group', $self->create_ad_group );
    $self->common_test_data( 'test_ad',       $self->create_ad );
    $self->common_test_data( 'test_ads',      [ $self->create_ads ] );
};


sub shutdown_test_ad_service : Test(shutdown) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    diag("cleaning test data...");
    $self->cleanup_ad;
    $self->cleanup_ads;
    $self->cleanup_ad_group;
    $self->cleanup_campaign;
};


sub test_can_add_ad : Test(4) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ad = $self->create_ad;

    ok( $ad );

    like( $ad->name, qr/^test ad \d+$/, 'name looks right' );
    like( $ad->ID, qr/^[\d]+$/, 'ID is numeric' );

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    ok( $ysm_ws->deleteAd( adID => $ad->ID, ), 'can delete ad');
}

sub test_dies_for_rejected_ad : Test(3) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );
    my $ad = Yahoo::Marketing::Ad->new
                 ->accountID( $ysm_ws->account )
                 ->adGroupID( $self->common_test_data( 'test_ad_group' )->ID )
                 ->name( 'test rejected ad ' )
                 ->status( 'On' )
                 ->title( 'faces of death pt 1' )
                 ->displayUrl( 'http://www.perl.com/' )
                 ->url( 'http://www.perl.com/' )
                 ->description( 'here\'s some great long description.  Not too long though.' )
                 ->shortDescription( 'here\'s some great short description' )
    ;

    ok( $ad );

    eval { $ysm_ws->addAd( Ad => $ad ) };

    ok( $@ );  # command failed
    like( $@, qr/Rejected/i, 'faces of death pt 1 is rejected' );
}


sub test_can_add_pending_ad : Test(8) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    my $ad = $ysm_ws->addAd( Ad => Yahoo::Marketing::Ad->new
                                       ->accountID( $ysm_ws->account )
                                       ->adGroupID( $self->common_test_data( 'test_ad_group' )->ID )
                                       ->name( 'test pending ad '.$$ )
                                       ->status( 'On' )
                                       ->title( 'Machine Gun Alley' )
                                       ->displayUrl( 'http://www.perl.com/' )
                                       ->url( 'http://www.perl.com/' )
                                       ->description( 'here\'s some great long description.  Not too long though.' )
                                       ->shortDescription( 'here\'s some great short description' )
                      );
    ok( $ad );

    like( $ad->ID, qr/^[\d]+$/, 'ID is numeric' );
    is(   $ad->name, "test pending ad $$", 'name looks right' );
    is(   $ad->title, 'Machine Gun Alley' );
    is(   $ad->status, 'On' );
    like( $ad->editorialStatus, qr/Approved|Pending/, 'editorial status is Approved or Pending' );    # this will be Pending in the future
    is(   $ad->pending, 'true' );

    ok( $ysm_ws->deleteAd( adID => $ad->ID, ), 'can delete ad');
}


sub test_can_get_pending_change_for_ad : Test(7) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    my $ad = $self->create_ad;

    ok( $ysm_ws->updateAd( ad => $ad->title( 'something illegal' ) ) );
    ok( $ysm_ws->updateAd( ad => $ad->shortDescription( 'something illegal but more descriptive' ) ) );

    my $pending_ad = $ysm_ws->getPendingChangeForAd( adID => $ad->ID );

    is( $pending_ad->ID,               $ad->ID,                                  'ID is correct' );
    is( $pending_ad->title,            'something illegal',                      'pending title is correct' );
    is( $pending_ad->shortDescription, 'something illegal but more descriptive', 'pending short description is correct' );
    is( $pending_ad->editorialStatus,  'Pending',                                'editorial status is pending' );

    ok( $ysm_ws->deleteAd( adID => $ad->ID, ), 'can delete ad');
}

sub test_can_add_ads : Test(8) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my @ads = $self->create_ads;

    ok( scalar @ads );

    foreach my $ad ( @ads ) {
        like( $ad->name, qr/^test ad \d+$/, 'name looks right' );
        like( $ad->ID, qr/^[\d]+$/, 'ID is numeric' );
    }

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    ok( $ysm_ws->deleteAds( adIDs => [ map { $_->ID } @ads ] , ), 'can delete ads');
}

sub test_can_delete_ad : Test(4) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ad = $self->create_ad;

    ok( $ad );

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    ok( $ysm_ws->deleteAd( adID => $ad->ID, ), 'can delete ad');

    my $fetched_ad = $ysm_ws->getAd( adID => $ad->ID );

    ok( $fetched_ad );
    is( $fetched_ad->status, 'Deleted', 'status is Deleted' );
}

sub test_can_delete_ads : Test(8) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my @ads = $self->create_ads;

    ok( scalar @ads );

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    ok( $ysm_ws->deleteAds( adIDs => [ map { $_->ID } @ads ] , ), 'can delete ads');

    my @fetched_ads = $ysm_ws->getAds( adIDs => [ map { $_->ID } @ads ] );

    foreach my $fetched_ad ( @fetched_ads ){
        ok( $fetched_ad );
        is( $fetched_ad->status, 'Deleted', 'status is Deleted' );
    }
}

sub test_get_status_for_ad : Test(1) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ad = $self->common_test_data( 'test_ad' );

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    is( $ysm_ws->getStatusForAd( adID => $ad->ID ), 'On', 'status is On' );
}

sub test_update_status_for_ad : Test(4) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ad = $self->common_test_data( 'test_ad' );

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    ok( $ysm_ws->updateStatusForAd( adID => $ad->ID, status => 'Off' ) );

    is( $ysm_ws->getStatusForAd( adID => $ad->ID ), 'Off', 'status is Off' );

    ok( $ysm_ws->updateStatusForAd( adID => $ad->ID, status => 'On' ) );

    is( $ysm_ws->getStatusForAd( adID => $ad->ID ), 'On', 'status is On' );
}

sub test_update_status_for_ads : Test(8) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my @ads = @{ $self->common_test_data( 'test_ads' ) };

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    ok( $ysm_ws->updateStatusForAds( adIDs => [ map { $_->ID } @ads ], status => 'Off' ) );

    foreach my $ad ( @ads ){
        is( $ysm_ws->getStatusForAd( adID => $ad->ID ), 'Off', 'status is Off' );
    }

    ok( $ysm_ws->updateStatusForAds( adIDs => [ map { $_->ID } @ads ], status => 'On' ) );

    foreach my $ad ( @ads ){
        is( $ysm_ws->getStatusForAd( adID => $ad->ID ), 'On', 'status is On' );
    }

}

sub test_update_ad : Test(8) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ad = $self->common_test_data( 'test_ad' );

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    ok( $ysm_ws->updateAd( ad => $ad->name( 'some updated ad name!' )
                                    ->status( 'Off' )
                                    ->title( 'second lamest title in the world' )
                                    ->displayUrl( 'http://www.cpan.org/' )
                                    ->url( 'http://www.perl.com/' )
                                    ->description( 'here\'s some lame long description. Not too long though.' )
                                    ->shortDescription( 'here\'s some lame short description' )

                 ) 
      );

    my $fetched_ad = $ysm_ws->getAd( adID => $ad->ID );

    ok( $fetched_ad );
    is( $fetched_ad->status,           'Off',                                 'status is Off' );
    is( $fetched_ad->title,            'second lamest title in the world',    'title is updated' );
    is( $fetched_ad->displayUrl,       'http://www.cpan.org/',                'displayUrl is updated' );
    is( $fetched_ad->url,              'http://www.perl.com/',                'url is updated' );
    is( $fetched_ad->description,      'here\'s some lame long description. Not too long though.', 'long description is updated' );
    is( $fetched_ad->shortDescription, 'here\'s some lame short description', 'short description is updated' );
}


sub test_update_ads : Test(22) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my @ads = @{ $self->common_test_data( 'test_ads' ) };

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    ok( $ysm_ws->updateAds( ads => [ $ads[0]->name( 'some updated name!' )
                                            ->status( 'Off' )
                                            ->title( 'second lamest title in the world' )
                                            ->displayUrl( 'http://www.cpan.org/' )
                                            ->url( 'http://www.perl.com/' )
                                            ->description( 'here\'s some lame long description.' )
                                            ->shortDescription( 'here\'s some lame short description' ),
                                     $ads[1]->name( 'another updated name!' )
                                            ->status( 'On' )
                                            ->title( 'third lamest title in the world' )
                                            ->displayUrl( 'http://www.cpan.org/' )
                                            ->url( 'http://www.yahoo.com/' )
                                            ->description( 'a great long description' )
                                            ->shortDescription( 'a great short description' ),
                                    ],
                 ) 
      );

    my $updated_ad = $ysm_ws->getAd( adID => $ads[0]->ID );

    ok( $updated_ad );
    is( $updated_ad->status,           'Off',                                 'status is Off' );
    is( $updated_ad->title,            'second lamest title in the world',    'title is updated' );
    is( $updated_ad->displayUrl,       'http://www.cpan.org/',                'displayUrl is updated' );
    is( $updated_ad->url,              'http://www.perl.com/',                'url is updated' );
    is( $updated_ad->description,      'here\'s some lame long description.', 'long description is updated' );
    is( $updated_ad->shortDescription, 'here\'s some lame short description', 'short description is updated' );

    $updated_ad = $ysm_ws->getAd( adID => $ads[1]->ID );

    ok( $updated_ad );
    is( $updated_ad->status,           'On',                                  'status is On' );
    is( $updated_ad->title,            'third lamest title in the world',     'title is updated' );
    is( $updated_ad->displayUrl,       'http://www.cpan.org/',                'displayUrl is updated' );
    is( $updated_ad->url,              'http://www.yahoo.com/',               'url is updated' );
    is( $updated_ad->description,      'a great long description',            'long description is updated' );
    is( $updated_ad->shortDescription, 'a great short description',           'short description is updated' );

    my $unchanged_ad = $ysm_ws->getAd( adID => $ads[2]->ID );

    ok( $unchanged_ad );
    is( $unchanged_ad->status,           $ads[2]->status,              'status is unchanged' );
    is( $unchanged_ad->title,            $ads[2]->title,               'title is unchanged' );
    is( $unchanged_ad->displayUrl,       $ads[2]->displayUrl,          'displayUrl is unchanged' );
    is( $unchanged_ad->url,              $ads[2]->url,                 'url is unchanged' );
    is( $unchanged_ad->description,      $ads[2]->description,         'long description is unchanged' );
    is( $unchanged_ad->shortDescription, $ads[2]->shortDescription,    'short description is unchanged' );
}

sub test_can_get_ad : Test(3) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my $ad = $self->common_test_data( 'test_ad' );

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    my $fetched_ad = $ysm_ws->getAd( adID => $ad->ID );

    ok( $fetched_ad );
    like( $fetched_ad->name, qr/^test ad \d+$/, 'name looks right' );
    like( $fetched_ad->ID, qr/^[\d]+$/, 'ID is numeric' );
}

sub test_can_get_ads : Test(10) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    my @ads = @{ $self->common_test_data( 'test_ads' ) };

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    my @fetched_ads = $ysm_ws->getAds( adIDs => [ map { $_->ID } @ads ] );

    ok( scalar @fetched_ads );

    foreach my $fetched_ad ( @fetched_ads ){
        ok( $fetched_ad );
        like( $fetched_ad->name, qr/^test ad \d+$/, 'name looks right' );
        like( $fetched_ad->ID, qr/^[\d]+$/, 'ID is numeric' );
    }
}


sub test_can_get_ads_by_ad_group_id_by_status : Test(18) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    # we need another ad group to add an ad to

    my $ad_group = $self->create_ad_group;

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    my $ad = Yahoo::Marketing::Ad->new
                                 ->accountID( $ysm_ws->account )
                                 ->adGroupID( $ad_group->ID )
                                 ->name( 'ad in other ad group '.$$ )
                                 ->status( 'On' )
                                 ->title( 'lamest title in the world' )
                                 ->displayUrl( 'http://www.perl.com/' )
                                 ->url( 'http://www.perl.com/' )
                                 ->description( 'here\'s some great long description.  Not too long though.' )
                                 ->shortDescription( 'here\'s some great short description' )
             ;
    my $added_ad = $ysm_ws->addAd( Ad => $ad );

    my @fetched_ads = $ysm_ws->getAdsByAdGroupIDByStatus( adGroupID => $ad_group->ID, status => 'On' );

    ok(   scalar @fetched_ads == 1,                              'got expected number of ads: 1');
    like( $fetched_ads[0]->name, qr/^ad in other ad group \d+$/, 'name looks right' );
    like( $fetched_ads[0]->ID,   qr/^[\d]+$/,                    'ID is numeric' );

    @fetched_ads = $ysm_ws->getAdsByAdGroupIDByStatus( adGroupID => $ad_group->ID, status => 'Off' );

    ok( scalar @fetched_ads == 0, 'got expected number of ads: 0' )
        or diag( "expected 0 ads, got ".( Dumper \@fetched_ads ) );

    @fetched_ads = $ysm_ws->getAdsByAdGroupIDByStatus( adGroupID => $self->common_test_data( 'test_ad_group' )->ID,
                                                       status    => 'On',
                                                     );

    my @test_ads = @{ $self->common_test_data( 'test_ads' ) };

    ok( scalar @fetched_ads );

    foreach my $fetched_ad ( @fetched_ads ){
        ok( $fetched_ad );
        like( $fetched_ad->name, qr/^test ad \d+$/, 'name looks right' );
        like( $fetched_ad->ID, qr/^[\d]+$/, 'ID is numeric' );
    }

    ok( my $foo = $ysm_ws->deleteAd( adID => $added_ad->ID, ), 'can delete ad' );

    $self->cleanup_ad_group( $ad_group );
}


sub test_can_get_ads_by_ad_group_id_by_editorial_status : Test(17) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    return 'waiting on next sandbox build';

    # we need another ad group to add an ad to

    my $ad_group = $self->create_ad_group;

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    my $ad = Yahoo::Marketing::Ad->new
                                 ->accountID( $ysm_ws->account )
                                 ->adGroupID( $ad_group->ID )
                                 ->name( 'ad in other ad group '.$$ )
                                 ->status( 'On' )
                                 ->title( 'machine gun' )
                                 ->displayUrl( 'http://www.perl.com/' )
                                 ->url( 'http://www.perl.com/' )
                                 ->description( 'here\'s some great long description.  Not too long though.' )
                                 ->shortDescription( 'here\'s some great short description' )
             ;
    $ad = $ysm_ws->addAd( Ad => $ad );

    is( $ad->pending, 'true', 'ad is pending' );
    is( $ad->editorialStatus, 'Pending', 'ad is pending' );

    my @fetched_ads = $ysm_ws->getAdsByAdGroupIDByEditorialStatus( adGroupID       => $ad_group->ID, 
                                                                   pendingChange   => 'True',
                                                                   status          => 'Pending',
                                                                 );

    @fetched_ads = $ysm_ws->getAdsByAdGroupIDByEditorialStatus( adGroupID       => $ad_group->ID, 
                                                                pendingChange   => 'true',
                                                                editorialStatus => 'Suspended',
                                                              );

    ok(   scalar @fetched_ads == 0, 'got expected number of ads: 0');

    @fetched_ads = $ysm_ws->getAdsByAdGroupIDByEditorialStatus( adGroupID       => $self->common_test_data( 'test_ad_group' )->ID,
                                                                pendingChange   => 'false',
                                                                editorialStatus => 'Approved',
                                                              );

    my @test_ads = @{ $self->common_test_data( 'test_ads' ) };

    ok( scalar @fetched_ads );

    foreach my $fetched_ad ( @fetched_ads ){
        next if $fetched_ad->status eq 'Deleted';
        ok( $fetched_ad );
        like( $fetched_ad->name, qr/^test ad \d+$/, 'name looks right' );
        like( $fetched_ad->ID, qr/^[\d]+$/, 'ID is numeric' );
    }

    ok( $ysm_ws->deleteAd( adID => $ad->ID, ), 'can delete ad');
    $self->cleanup_ad_group( $ad_group );
}

sub test_can_get_ads_by_ad_group_id : Test(12) {
    my ( $self ) = @_;

    return 'not running post tests' unless $self->run_post_tests;

    # we need 2 new ad groups for a good test - we can't use the one we created at setup,
    #   because we get all the Deleted adds from previous tests too

    my $ad_group1 = $self->create_ad_group;
    my $ad_group2 = $self->create_ad_group;

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    my $ad = Yahoo::Marketing::Ad->new
                                 ->accountID( $ysm_ws->account )
                                 ->adGroupID( $ad_group1->ID )
                                 ->name( 'ad in new ad group '.$$ )
                                 ->status( 'On' )
                                 ->title( 'lamest title in the world' )
                                 ->displayUrl( 'http://www.perl.com/' )
                                 ->url( 'http://www.perl.com/' )
                                 ->description( 'here\'s some great long description.  Not too long though.' )
                                 ->shortDescription( 'here\'s some great short description' )
             ;
    my $added_ad = $ysm_ws->addAd( Ad => $ad );

    my $ad1 = Yahoo::Marketing::Ad->new
                                  ->accountID( $ysm_ws->account )
                                  ->adGroupID( $ad_group2->ID )
                                  ->name( 'ad in other new ad group '.($$ + 1) )
                                  ->status( 'On' )
                                  ->title( 'lamest title in the world' )
                                  ->displayUrl( 'http://www.perl.com/' )
                                  ->url( 'http://www.perl.com/' )
                                  ->description( 'here\'s some great long description.  Not too long though.' )
                                  ->shortDescription( 'here\'s some great short description' )
              ;

    my $ad2 = Yahoo::Marketing::Ad->new
                                  ->accountID( $ysm_ws->account )
                                  ->adGroupID( $ad_group2->ID )
                                  ->name( 'ad in other new ad group '.($$ + 2) )
                                  ->status( 'On' )
                                  ->status( 'Off' )
                                  ->title( 'lamest title in the world' )
                                  ->displayUrl( 'http://www.perl.com/' )
                                  ->url( 'http://www.perl.com/' )
                                  ->description( 'here\'s some great long description.  Not too long though.' )
                                  ->shortDescription( 'here\'s some great short description' )
              ;
    my @added_ads = $ysm_ws->addAds( ads => [ $ad1, $ad2 ]);

    my @fetched_ads = $ysm_ws->getAdsByAdGroupID( adGroupID => $ad_group1->ID );

    ok(   scalar @fetched_ads == 1,                              'got expected number of ads: 1' );
    like( $fetched_ads[0]->name, qr/^ad in new ad group \d+$/, 'name looks right' );
    like( $fetched_ads[0]->ID,   qr/^[\d]+$/,                    'ID is numeric' );


    @fetched_ads = grep { $_->status ne 'Deleted' } $ysm_ws->getAdsByAdGroupID( adGroupID => $ad_group2->ID );

    my @test_ads = @{ $self->common_test_data( 'test_ads' ) };

    ok( scalar @fetched_ads == 2, 'got exepected number of ads in other ad group: 2' );

    is( $fetched_ads[0]->ID,     $added_ads[0]->ID,       'ID is correct' );
    is( $fetched_ads[0]->name,   $added_ads[0]->name,     'name is correct' );
    is( $fetched_ads[0]->status, $added_ads[0]->status,   'status is correct' );

    is( $fetched_ads[1]->ID,     $added_ads[1]->ID,       'ID is correct' );
    is( $fetched_ads[1]->name,   $added_ads[1]->name,     'name is correct' );
    is( $fetched_ads[1]->status, $added_ads[1]->status,   'status is correct' );

    ok( $ysm_ws->deleteAd(  adID  => $added_ad->ID, ),                'can delete ad');
    ok( $ysm_ws->deleteAds( adIDs => [ map { $_->ID } @added_ads ] ), 'can delete ad');
    $self->cleanup_ad_group( $ad_group1 );
    $self->cleanup_ad_group( $ad_group2 );
}


1;

__END__

operations:
    * addAd
    * addAds
    * deleteAd
    * deleteAds
    * getAd
    * getAds
    * getAdsByAdGroupID
    * getAdsByAdGroupIDByEditorialStatus
    * getAdsByAdGroupIDByStatus
    * getEditorialReasonsForAd
    * getEditorialReasonText
    * getPendingChangeForAd
    * getStatusForAd
    * updateAd
    * updateAds
    * updateStatusForAd
    * updateStatusForAds


