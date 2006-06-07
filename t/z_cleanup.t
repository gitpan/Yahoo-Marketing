#!perl 
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;
use Test::More tests => 2;


use Data::Dumper;
use Module::Build;
use Yahoo::Marketing::AdGroup;
use Yahoo::Marketing::Campaign;
use Yahoo::Marketing::AdGroupService;
use Yahoo::Marketing::KeywordService;
use Yahoo::Marketing::CampaignService;

#use SOAP::Lite +trace => [qw/ debug method fault /]; #global debug for SOAP calls


# cleanup campaigns

my $build = Module::Build->current;
SKIP: { 
    skip 'not running post tests', 2, unless $build->notes( 'run_post_tests' ) 
                                         and $build->notes( 'run_post_tests' ) =~ /^y/i;


    my $keyword_service  = Yahoo::Marketing::KeywordService->new->parse_config(  section => 'sandbox' );
    my $ad_group_service = Yahoo::Marketing::AdGroupService->new->parse_config(  section => 'sandbox' );
    my $campaign_service = Yahoo::Marketing::CampaignService->new->parse_config( section => 'sandbox' );



    my @keywords = grep { defined $_ and $_ ne '' and $_->status ne 'Deleted' } 
    my @foo  =         $keyword_service->getKeywordsByAccountID(
                                             accountID    => $keyword_service->account,
                                             startElement => 0,
                                             endElement   => 1000,
                                         );



    if( @keywords ){

        ok( $keyword_service->deleteKeywords( keywordIDs => [ map { $_->ID } @keywords ], ) );
        diag( ( scalar @keywords ) . " keywords have been deleted successfully." );
    }else{
        ok( 1 );
        diag( 'no keywords found.' );
    }


    my @campaigns = grep { defined $_ and $_->status ne 'Deleted' } 
                        $campaign_service->getCampaignsByAccountID(
                                     accountID => $campaign_service->account,
                                 );

    if( @campaigns ){

        foreach my $campaign ( @campaigns ){
            my @ad_groups = grep { defined $_ and $_->status ne 'Deleted' } 
                                $ad_group_service->getAdGroupsByCampaignID(
                                    campaignID => $campaign->ID,
                                    startElement => 0,
                                    endElement   => 1000,
                                );

            if( @ad_groups ){
                $ad_group_service->deleteAdGroups( adGroupIDs => [ map { $_->ID } @ad_groups ], );
                diag( ( scalar @ad_groups ) . " adGroups have been deleted successfully." );
            }else{
                diag( 'no adGroups found.' );
            }
        }

        ok( $campaign_service->deleteCampaigns( campaignIDs => [ map { $_->ID } @campaigns ], ));
        diag( ( scalar @campaigns ) . " campaigns have been deleted successfully." );
    }else{
        ok( 1 );
        diag( 'no campaigns found.' );
    }
}

