package Yahoo::Marketing::Test::BasicReportService;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/ Yahoo::Marketing::Test::PostTest /;
use Test::More;
use Module::Build;

use Yahoo::Marketing::BasicReportRequest;
use Yahoo::Marketing::BasicReportService;
use Yahoo::Marketing::ReportInfo;
use Yahoo::Marketing::FileOutputFormat;
#use SOAP::Lite +trace => [qw/ debug method fault /];

my $section = 'sandbox';

sub SKIP_CLASS {
    my $self = shift;
    # 'not running post tests' is a true value
    return 'not running post tests' unless $self->run_post_tests;
    return;
}

sub test_is_books_closed : Test(1) {
    my $self = shift;

    my $ysm_ws = Yahoo::Marketing::BasicReportService->new->parse_config( section => $section );

    my $basic_report_request = Yahoo::Marketing::BasicReportRequest->new
        ->reportName( 'account aggregation report' )
        ->reportType( 'AccountSummary' )
        ->dateRange( 'LastCalendarMonth' );

    my $result = $ysm_ws->isBooksClosed(
        reportRequest => $basic_report_request,
    );
    ok($result);
};


sub test_add_report_request_with_account_aggregation : Test(2) {
    my $self = shift;

    my $ysm_ws = Yahoo::Marketing::BasicReportService->new->parse_config( section => $section );

    my $basic_report_request = Yahoo::Marketing::BasicReportRequest->new
        ->reportName( 'account aggregation report' )
        ->reportType( 'AccountSummary' )
        ->dateRange( 'LastCalendarMonth' );

    my $reportID = $ysm_ws->addReportRequestWithAccountAggregation(
        reportRequest => $basic_report_request,
    );

    ok( $reportID );
    like( $reportID, qr/^\d+$/, 'reportID looks right' );
};


sub test_add_report_request_for_account_id : Test(2) {
    my $self = shift;

    my $ysm_ws = Yahoo::Marketing::BasicReportService->new->parse_config( section => $section );

    my $basic_report_request = Yahoo::Marketing::BasicReportRequest->new
        ->reportName( 'account report' )
        ->reportType( 'CampaignSummary' )
        ->dateRange( 'WeekToDate' );

    my $reportID = $ysm_ws->addReportRequestForAccountID(
        accountID => $ysm_ws->account,
        reportRequest => $basic_report_request,
    );

    ok( $reportID );
    like( $reportID, qr/^\d+$/, 'reportID looks right' );
};


sub test_get_report_list : Test(2) {
    my $self = shift;

    my $ysm_ws = Yahoo::Marketing::BasicReportService->new->parse_config( section => $section );

    my $basic_report_request = Yahoo::Marketing::BasicReportRequest->new
        ->reportName( 'account report for testing get report list' )
        ->reportType( 'AdvancedAdKeywordPerformance' )
        ->dateRange( 'MonthToDate' );

    my $reportID = $ysm_ws->addReportRequestForAccountID(
        accountID => $ysm_ws->account,
        reportRequest => $basic_report_request,
    );

    my @report_info = $ysm_ws->getReportList(
        onlyCompleted => 'false',
    );

    ok( @report_info );

    my $found = 0;
    foreach my $info ( @report_info ) {
        $found = 1 if $info->reportID and $info->reportID == $reportID
    }

    is( $found, 1 );
};


sub test_delete_report : Test(2) {
    my $self = shift;

    my $ysm_ws = Yahoo::Marketing::BasicReportService->new->parse_config( section => $section );

    my $basic_report_request = Yahoo::Marketing::BasicReportRequest->new
        ->reportName( 'account report for testing delete' )
        ->reportType( 'KeywordSummary' )
        ->dateRange( 'LastBusinessWeek' );

    my $reportID = $ysm_ws->addReportRequestForAccountID(
        accountID => $ysm_ws->account,
        reportRequest => $basic_report_request,
    );

    ok( $reportID );

    $ysm_ws->deleteReport(
        reportID => $reportID,
    );

    my @report_info = $ysm_ws->getReportList(
        onlyCompleted => 'false',
    );

    my $found = 0;
    for my $info ( @report_info ) {
        $found = 1 if $info->reportID == $reportID;
    }
    is( $found, 0 );
}


sub test_delete_reports : Test(3) {
    my $self = shift;

    my $ysm_ws = Yahoo::Marketing::BasicReportService->new->parse_config( section => $section );

    my $basic_report_request1 = Yahoo::Marketing::BasicReportRequest->new
        ->reportName( 'account report 1 for testing delete' )
        ->reportType( 'AdGroupSummary' )
        ->dateRange( 'Last7Days' );

    my $reportID1 = $ysm_ws->addReportRequestForAccountID(
        accountID => $ysm_ws->account,
        reportRequest => $basic_report_request1,
    );

    ok( $reportID1 );

    my $basic_report_request2 = Yahoo::Marketing::BasicReportRequest->new
        ->reportName( 'account report 2 for testing delete' )
        ->reportType( 'AccountSummary' )
        ->dateRange( 'Last30Days' );

    my $reportID2 = $ysm_ws->addReportRequestForAccountID(
        accountID => $ysm_ws->account,
        reportRequest => $basic_report_request2,
    );

    ok( $reportID2 );

    $ysm_ws->deleteReports(
        reportIDs => [ $reportID1, $reportID2 ],
    );

    my @report_info = $ysm_ws->getReportList(
        onlyCompleted => 'false',
    );

    my $found = 0;
    for my $info ( @report_info ) {
        $found = 1 if ( $info->reportID == $reportID1 ) or ( $info->reportID == $reportID2 );
    }
    is( $found, 0 );
}


sub test_get_report_output_url : Test(2) {
    my $self = shift;

    my $ysm_ws = Yahoo::Marketing::BasicReportService->new->parse_config( section => $section );

    my $basic_report_request = Yahoo::Marketing::BasicReportRequest->new
        ->reportName( 'account report for getting output url test' )
        ->reportType( 'AdGroupSummary' )
        ->dateRange( 'LastCalendarQuarter' );

    my $reportID = $ysm_ws->addReportRequestForAccountID(
        accountID => $ysm_ws->account,
        reportRequest => $basic_report_request,
    );

    my $retry = 5;
    my @ready;
    for ( my $i = 1; $i <= $retry; $i++ ) {
        my @report_info = $ysm_ws->getReportList(
            onlyCompleted => 'true',
        );
        @ready = grep { $_->reportID and $_->reportID == $reportID } @report_info and last if @report_info;
        sleep 5;
    }

    return 'report pending for too long time, skip test of getReportOutputUrl(s)' unless @ready;

    my $file_output_format = Yahoo::Marketing::FileOutputFormat->new
        ->fileOutputType( 'CSV' )
        ->zipped( 'true' );

    my $report_url = $ysm_ws->getReportOutputUrl(
        reportID   => $reportID,
        fileFormat => $file_output_format,
    );

    ok( $report_url );
    like( $report_url, qr{^http(s?)://}, 'looks like a URL' );
};


sub test_get_report_output_urls : Test(4) {
    my $self = shift;

    my $ysm_ws = Yahoo::Marketing::BasicReportService->new->parse_config( section => $section );

    my $basic_report_request1 = Yahoo::Marketing::BasicReportRequest->new
        ->reportName( 'account report for getting output urls test' )
        ->reportType( 'CampaignSummary' )
        ->dateRange( 'Yesterday' );

    my $reportID1 = $ysm_ws->addReportRequestForAccountID(
        accountID => $ysm_ws->account,
        reportRequest => $basic_report_request1,
    );

    my $basic_report_request2 = Yahoo::Marketing::BasicReportRequest->new
        ->reportName( 'account report for getting output urls test' )
        ->reportType( 'DailySummary' )
        ->dateRange( 'LastCalendarWeek' );

    my $reportID2 = $ysm_ws->addReportRequestForAccountID(
        accountID => $ysm_ws->account,
        reportRequest => $basic_report_request2,
    );

    my $retry = 5;
    my @ready;
    for ( my $i = 1; $i <= $retry; $i++ ) {
        my @report_info = $ysm_ws->getReportList(
            onlyCompleted => 'true',
        );

        @ready = grep { $_->reportID and ( $_->reportID == $reportID1 or $_->reportID == $reportID2 ) } @report_info if @report_info;
        last if ( scalar @ready == 2 );
        sleep 5;
        @ready = ();
    }

    return 'report pending for too long time, skip test of getReportOutputUrl(s)' unless @ready;

    my $file_output_format = Yahoo::Marketing::FileOutputFormat->new
        ->fileOutputType( 'XML' )
        ->zipped( 'false' );

    my @report_urls = $ysm_ws->getReportOutputUrls(
        reportIDs   => [ $reportID1, $reportID2 ],
        fileFormat  => $file_output_format,
    );

    ok( @report_urls );
    is( scalar @report_urls, 2 );
    like( $report_urls[0], qr{^http(s?)://}, 'looks like a URL' );
    like( $report_urls[1], qr{^http(s?)://}, 'looks like a URL' );
};

sub test_only_hold_5_reports : Test(4) {

    my $self = shift;

    my $ysm_ws = Yahoo::Marketing::BasicReportService->new->parse_config( section => $section );
    my @report_list = $ysm_ws->getReportList( onlyCompleted => 'false' );

    ok( @report_list <= 5, 'less then 5' );

    foreach my $i ( 1..6 ) {
        my $basic_report_request = Yahoo::Marketing::BasicReportRequest->new
            ->reportName( "account aggregation report $i" )
            ->reportType( 'AccountSummary' )
            ->dateRange( 'LastCalendarMonth' );
        my $reportID = $ysm_ws->addReportRequestWithAccountAggregation(
            reportRequest => $basic_report_request,
        );
    }

    @report_list = $ysm_ws->getReportList( onlyCompleted => 'false' );
    ok( @report_list <= 5, 'less then 5' );

    ok( $report_list[0]->reportName eq 'account aggregation report 6' );
    ok( $report_list[4]->reportName eq 'account aggregation report 2' );
}


1;


__END__

# addReportRequestWithAccountAggregation
# addReportRequestForAccountID
# deleteReport
# deleteReports
# getReportList
# getReportOutputUrl
# getReportOutputUrls
