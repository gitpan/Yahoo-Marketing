package Yahoo::Marketing::TEST::BasicReportRequest;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::BasicReportRequest;

sub test_can_create_basic_report_request_and_set_all_fields : Test(6) {

    my $basic_report_request = Yahoo::Marketing::BasicReportRequest->new
                                                                   ->dateRange( 'date range' )
                                                                   ->endDate( 'end date' )
                                                                   ->reportName( 'report name' )
                                                                   ->reportType( 'report type' )
                                                                   ->startDate( 'start date' )
                   ;

    ok( $basic_report_request );

    is( $basic_report_request->dateRange, 'date range', 'can get date range' );
    is( $basic_report_request->endDate, 'end date', 'can get end date' );
    is( $basic_report_request->reportName, 'report name', 'can get report name' );
    is( $basic_report_request->reportType, 'report type', 'can get report type' );
    is( $basic_report_request->startDate, 'start date', 'can get start date' );

};



1;

