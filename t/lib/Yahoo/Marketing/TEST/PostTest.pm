package Yahoo::Marketing::TEST::PostTest;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;

use Carp;
use Module::Build;
use Yahoo::Marketing::Campaign;
use Yahoo::Marketing::AdGroup;
use Yahoo::Marketing::Ad;
use Yahoo::Marketing::Keyword;
use Yahoo::Marketing::AdService;
use Yahoo::Marketing::CampaignService;
use Yahoo::Marketing::AccountService;
use Yahoo::Marketing::AdGroupService;
use Yahoo::Marketing::KeywordService;
# remove Dumper before release.
use Data::Dumper;

our %common_test_data;
my $section = 'sandbox';

sub common_test_data {
    my ( $self, $key, $value ) = @_;

    die "common_test_data_value needs a key" unless defined $key;

    if( @_ > 2 ){  # we have a value
        #confess "common_test_data called with $key but an undef \$value" unless defined $value;
        $common_test_data{ $key } = $value;
        return $self;
    }

    return $common_test_data{ $key };
}


sub cleanup_all {
    my $self = shift;

    $self->cleanup_campaign;
    $self->cleanup_campaigns;
    $self->cleanup_ad_group;
    $self->cleanup_ad_groups;
    $self->cleanup_ad;
    $self->cleanup_keyword;
    $self->cleanup_keywords;
}

sub cleanup_keyword {
    my $self = shift;

    if( my $keyword = $self->common_test_data( 'test_keyword' ) ){
        my $keyword_service = Yahoo::Marketing::KeywordService->new->parse_config( section => $section );
        $keyword_service->deleteKeyword( keywordID => $keyword->ID );
    }
    $self->common_test_data( 'test_keyword', undef );
    return;
}

sub cleanup_keywords {
    my $self = shift;

    if ($self->common_test_data( 'test_keywords' ) ){

        my $keyword_service = Yahoo::Marketing::KeywordService->new->parse_config( section => $section );
        $keyword_service->deleteKeywords( keywordIDs => [ map { $_->ID } @{ $self->common_test_data( 'test_keywords' ) } ] );
    }
    $self->common_test_data( 'test_keywords', undef );
    return;
}

sub cleanup_ad {
    my $self = shift;

    if( my $ad = $self->common_test_data( 'test_ad' ) ){
        my $ad_service = Yahoo::Marketing::AdService->new->parse_config( section => $section );
        $ad_service->deleteAd( adID => $ad->ID );
    }
    $self->common_test_data( 'test_ad', undef );
    return;
}

sub cleanup_ads {
    my $self = shift;

    if ($self->common_test_data( 'test_ads' ) ){

        my $ad_service = Yahoo::Marketing::AdService->new->parse_config( section => $section );
        $ad_service->deleteAds( adIDs => [ map { $_->ID } @{ $self->common_test_data( 'test_ads' ) } ] );
    }
    $self->common_test_data( 'test_ads', undef );
    return;
}

sub cleanup_ad_group {
    my ( $self, $ad_group ) = @_;

    unless( $ad_group ){
        $ad_group = $self->common_test_data( 'test_ad_group' );
        $self->common_test_data( 'test_ad_group', undef );
    }
    
    if( $ad_group ){
        my $ad_group_service = Yahoo::Marketing::AdGroupService->new->parse_config( section => $section );
        $ad_group_service->deleteAdGroup( adGroupID => $ad_group->ID );
    }
    return;
}

sub cleanup_ad_groups {
    my $self = shift;

    if ($self->common_test_data( 'test_ad_groups' ) ){
        my $ad_group_service = Yahoo::Marketing::AdGroupService->new->parse_config( section => $section );

        $ad_group_service->deleteAdGroups( adGroupIDs => [ map { $_->ID } @{ $self->common_test_data( 'test_ad_groups' ) } ] );
    }
    $self->common_test_data( 'test_ad_groups', undef );
    return;
}

sub cleanup_all_ad_groups_in_test_campaign {
    my $self = shift;

    if ( my $campaign = $self->common_test_data( 'test_campaign' ) ) {
        my $ad_group_service = Yahoo::Marketing::AdGroupService->new->parse_config( section => $section );
        my @ad_groups = $ad_group_service->getAdGroupsByCampaignID(
            campaignID => $campaign->ID,
        );
        $ad_group_service->deleteAdGroups(
            adGroupIDs => [ grep { $_->ID } @ad_groups ],
        ) if @ad_groups;
    }
    $self->common_test_data( 'test_ad_group', undef );
    $self->common_test_data( 'test_ad_groups', undef );
    return;
}

sub cleanup_campaign {
    my $self = shift;

    if( my $campaign = $self->common_test_data( 'test_campaign' ) ){
        my $campaign_service = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

        $campaign_service->deleteCampaign( campaignID => $campaign->ID );
    }
    $self->common_test_data( 'test_campaign', undef );
    return;
}

sub cleanup_campaigns {
    my $self = shift;

    if ( $self->common_test_data( 'test_campaigns' ) ){
        my $campaign_service = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

        $campaign_service->deleteCampaigns( campaignIDs => [ map { $_->ID } @{ $self->common_test_data( 'test_campaigns' ) } ] );
    }
    $self->common_test_data( 'test_campaigns', undef );
    return;
}

sub cleanup_campaigns_in_test_account {
    my $self = shift;

    my $campaign_service = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    return unless $campaign_service->account;

    my @campaigns = $campaign_service->getCampaignsByAccountIDByCampaignStatus(
        accountID => $campaign_service->account,
        status    => 'On',
    ) || ();
    push @campaigns,
        $campaign_service->getCampaignsByAccountIDByCampaignStatus(
            accountID => $campaign_service->account,
            status    => 'Off',
        ) || ();

#    $campaign_service->deleteCampaigns( campaignIDs => [ map { $_->ID } @campaigns ] );
    for my $campaign (@campaigns) {
        $campaign_service->deleteCampaign( campaignID => $campaign->ID );
    }
    $self->common_test_data( 'test_campaign', undef );
    $self->common_test_data( 'test_campaigns', undef );
    return;
}

sub run_post_tests {
    my $self = shift;

    my $build = Module::Build->current;
    return $build->notes( 'run_post_tests' )
       and $build->notes( 'run_post_tests' ) =~ /^y/i;
}


# helper methods........
our $campaign_count = 0;
sub create_campaign {
    my ( $self, %args ) = @_;

    my $formatter = DateTime::Format::W3CDTF->new;
    my $datetime = DateTime->now;
    $datetime->set_time_zone( 'America/Chicago' );
    $datetime->add( days => 1 );

    my $start_datetime = $formatter->format_datetime( $datetime );

    $datetime->add( years => 1 );
    my $end_datetime   = $formatter->format_datetime( $datetime );

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my $campaign = Yahoo::Marketing::Campaign->new
                                             ->startDate( $start_datetime )
                                             ->endDate(   $end_datetime )
                                             ->name( 'test campaign '.($$ + $campaign_count++) )
                                             ->status( 'On' )
                                             ->accountID( $ysm_ws->account )
                   ;

    return  $ysm_ws->addCampaign( campaign => $campaign );
}

sub create_campaigns {
    my ( $self, %args ) = @_;

    my $formatter = DateTime::Format::W3CDTF->new;
    my $datetime = DateTime->now;
    $datetime->set_time_zone( 'America/Chicago' );
    $datetime->add( days => 1 );

    my $start_datetime = $formatter->format_datetime( $datetime );

    $datetime->add( years => 1 );
    my $end_datetime   = $formatter->format_datetime( $datetime );

    my $ysm_ws = Yahoo::Marketing::CampaignService->new->parse_config( section => $section );

    my $campaign1 = Yahoo::Marketing::Campaign->new
                                              ->startDate( $start_datetime )
                                              ->endDate(   $end_datetime )
                                              ->name( 'test campaign '.($$ + $campaign_count++).' 1' )
                                              ->status( 'On' )
                                              ->accountID( $ysm_ws->account )
                    ;
    my $campaign2 = Yahoo::Marketing::Campaign->new
                                              ->startDate( $start_datetime )
                                              ->endDate(   $end_datetime )
                                              ->name( 'test campaign '.($$ + $campaign_count++).' 2' )
                                              ->status( 'On' )
                                              ->accountID( $ysm_ws->account )
                    ;
    my $campaign3 = Yahoo::Marketing::Campaign->new
                                              ->startDate( $start_datetime )
                                              ->endDate(   $end_datetime )
                                              ->name( 'test campaign '.($$ + $campaign_count++).' 3' )
                                              ->status( 'On' )
                                              ->accountID( $ysm_ws->account )
                    ;

    return ( $ysm_ws->addCampaigns( campaigns => [ $campaign1, $campaign2, $campaign3 ] ) );
}

our $ad_group_count = 0;
sub create_ad_group {
    my ( $self, %args ) = @_;
    my $campaign = $self->common_test_data( 'test_campaign' );

    my $ad_group = Yahoo::Marketing::AdGroup->new
                                            ->campaignID( $campaign->ID )
                                            ->name( 'test ad group '.($$ + $ad_group_count++) )
                                            ->status( 'On' )
                                            ->contentMatchON( 'true' )
                                            ->contentMatchMaxBid( '0.18' )
                                            ->sponsoredSearchON( 'true' )
                                            ->sponsoredSearchMaxBid( '0.28' )
                   ;

    my $ysm_ws = Yahoo::Marketing::AdGroupService->new->parse_config( section => $section );

    my $added_ad_group = $ysm_ws->addAdGroup( adGroup => $ad_group );

    return $added_ad_group;
}

sub create_ad_groups {
    my ( $self ) = @_;

    my $campaign = $self->common_test_data( 'test_campaign' );
    # contentMatchMaxBid and sponsoredSearchMaxBid should NOT be required,
    # but for the bug in java code, they have to present for now.
    my $ad_group1 = Yahoo::Marketing::AdGroup->new
                                             ->campaignID( $campaign->ID )
                                             ->name( 'test ad group '.($$ + $ad_group_count++).' 1' )
                                             ->status( 'On' )
                                             ->contentMatchON( 'true' )
                                             ->contentMatchMaxBid( '0.18' )
                                             ->sponsoredSearchON( 'true' )
                                             ->sponsoredSearchMaxBid( '0.28' )
                    ;

    my $ad_group2 = Yahoo::Marketing::AdGroup->new
                                             ->campaignID( $campaign->ID )
                                             ->name( 'test ad group '.($$ + $ad_group_count++).' 2' )
                                             ->status( 'On' )
                                             ->contentMatchON( 'true' )
                                             ->contentMatchMaxBid( '0.18' )
                                             ->sponsoredSearchON( 'true' )
                                             ->sponsoredSearchMaxBid( '0.28' )
                    ;

    my $ad_group3 = Yahoo::Marketing::AdGroup->new
                                             ->campaignID( $campaign->ID )
                                             ->name( 'test ad group '.($$ + $ad_group_count++).' 3' )
                                             ->status( 'On' )
                                             ->contentMatchON( 'true' )
                                             ->contentMatchMaxBid( '0.18' )
                                             ->sponsoredSearchON( 'true' )
                                             ->sponsoredSearchMaxBid( '0.28' )
                    ;

    my $ysm_ws = Yahoo::Marketing::AdGroupService->new->parse_config( section => $section );

    my @added_ad_groups = $ysm_ws->addAdGroups( adGroups => [ $ad_group1, $ad_group2, $ad_group3 ] );

    return @added_ad_groups;
}

our $ad_count = 0;
sub create_ad {
    my ( $self ) = @_;

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => 'sandbox' );

    my $ad = Yahoo::Marketing::Ad->new
                                 ->accountID( $ysm_ws->account )
                                 ->adGroupID( $self->common_test_data( 'test_ad_group' )->ID )
                                 ->name( 'test ad '.($$ + $ad_count++) )
                                 ->status( 'On' )
                                 ->title( 'lamest title in the world' )
                                 ->displayUrl( 'http://www.perl.com/' )
                                 ->url( 'http://www.perl.com/' )
                                 ->description( 'here\'s some great long description.  Not too long though.' )
                                 ->shortDescription( 'here\'s some great short description' )
             ;

    return $ysm_ws->addAd( Ad => $ad );
}

sub create_ads {
    my ( $self ) = @_;

    my $campaign = $self->common_test_data( 'test_campaign' );

    my $ysm_ws = Yahoo::Marketing::AdService->new->parse_config( section => $section );

    my $ad1 = Yahoo::Marketing::Ad->new
                                  ->accountID( $ysm_ws->account )
                                  ->adGroupID( $self->common_test_data( 'test_ad_group' )->ID )
                                  ->name( 'test ad '.($$ + $ad_count++) )
                                  ->status( 'On' )
                                  ->title( 'lamest title in the world' )
                                  ->displayUrl( 'http://www.perl.com/' )
                                  ->url( 'http://www.perl.com/' )
                                  ->description( 'here\'s some great long description.  Not too long though.' )
                                  ->shortDescription( 'here\'s some great short description' )
              ;
    my $ad2 = Yahoo::Marketing::Ad->new
                                  ->accountID( $ysm_ws->account )
                                  ->adGroupID( $self->common_test_data( 'test_ad_group' )->ID )
                                  ->name( 'test ad '.($$ + $ad_count++) )
                                  ->status( 'On' )
                                  ->title( 'lamest title in the world' )
                                  ->displayUrl( 'http://www.perl.com/' )
                                  ->url( 'http://www.perl.com/' )
                                  ->description( 'here\'s some great long description.  Not too long though.' )
                                  ->shortDescription( 'here\'s some great short description' )
              ;
    my $ad3 = Yahoo::Marketing::Ad->new
                                  ->accountID( $ysm_ws->account )
                                  ->adGroupID( $self->common_test_data( 'test_ad_group' )->ID )
                                  ->name( 'test ad '.($$ + $ad_count++) )
                                  ->status( 'On' )
                                  ->title( 'lamest title in the world' )
                                  ->displayUrl( 'http://www.perl.com/' )
                                  ->url( 'http://www.perl.com/' )
                                  ->description( 'here\'s some great long description.  Not too long though.' )
                                  ->shortDescription( 'here\'s some great short description' )
              ;


    my @added_ads = $ysm_ws->addAds( ads => [ $ad1, $ad2, $ad3 ] );

    return @added_ads;
}


our $keyword_count = 0;
sub create_keyword {
    my ( $self, %args ) = @_;

    my $text = $args{text} || ('test keyword text '.( $$ + $keyword_count ));

    my $ysm_ws = Yahoo::Marketing::KeywordService->new->parse_config( section => 'sandbox' );

    my $keyword = Yahoo::Marketing::Keyword->new
                                           ->adGroupID( $self->common_test_data( 'test_ad_group' )->ID )
                                           ->text( $text )
                                           ->alternateText( 'test keyword alternate text '.( $$ + $keyword_count ) )
                                           ->sponsoredSearchMaxBid( 1 )
                                           ->status( 'On' )
                                           ->watchON( 'true' )
                                           ->advancedMatchON( 'true' )
                                           ->url( 'http://www.yahoo.com/testkeyword?id='.( $$ + $keyword_count ) )
                  ;

    $keyword_count++;
    return $ysm_ws->addKeyword( keyword => $keyword );
}

sub create_keywords {
    my ( $self, %args ) = @_;

    my $ysm_ws = Yahoo::Marketing::KeywordService->new->parse_config( section => $section );

    my $keyword1 = Yahoo::Marketing::Keyword->new
                                            ->adGroupID( $self->common_test_data( 'test_ad_group' )->ID )
                                            ->text( 'test keyword text '.( $$ + $keyword_count ) )
                                            ->alternateText( 'test keyword alternate text '.( $$ + $keyword_count ) )
                                            ->sponsoredSearchMaxBid( 1 )
                                            ->status( 'On' )
                                            ->watchON( 'true' )
                                            ->advancedMatchON( 'true' )
                                            ->url( 'http://www.yahoo.com/testkeyword?id='.( $$ + $keyword_count++ ) )
                    ;
    my $keyword2 = Yahoo::Marketing::Keyword->new
                                            ->adGroupID( $self->common_test_data( 'test_ad_group' )->ID )
                                            ->text( 'test keyword text '.( $$ + $keyword_count ) )
                                            ->alternateText( 'test keyword alternate text '.( $$ + $keyword_count ) )
                                            ->sponsoredSearchMaxBid( 1 )
                                            ->status( 'On' )
                                            ->watchON( 'true' )
                                            ->advancedMatchON( 'true' )
                                            ->url( 'http://www.yahoo.com/testkeyword?id='.( $$ + $keyword_count++ ) )
                    ;
    my $keyword3 = Yahoo::Marketing::Keyword->new
                                            ->adGroupID( $self->common_test_data( 'test_ad_group' )->ID )
                                            ->text( 'test keyword text '.( $$ + $keyword_count ) )
                                            ->alternateText( 'test keyword alternate text '.( $$ + $keyword_count ) )
                                            ->sponsoredSearchMaxBid( 1 )
                                            ->status( 'On' )
                                            ->watchON( 'true' )
                                            ->advancedMatchON( 'true' )
                                            ->url( 'http://www.yahoo.com/testkeyword?id='.( $$ + $keyword_count++ ) )
                    ;

    return ( $ysm_ws->addKeywords( keywords => [ $keyword1, $keyword2, $keyword3 ] ) );
}

BEGIN {
    if( __PACKAGE__->run_post_tests ){

        eval { require YAML;
               require DateTime;
               require DateTime::Format::W3CDTF;
             };
        die "running post tests requires the following CPAN modules:
    YAML
    DateTime
    DateTime::Format::W3CDTF

Please make sure they're properly installed on your system.  
" if $@;
    }
}


1;
