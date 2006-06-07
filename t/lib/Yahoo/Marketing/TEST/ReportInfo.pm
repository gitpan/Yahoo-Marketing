package Yahoo::Marketing::TEST::ReportInfo;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::ReportInfo;

sub test_can_create_report_info_and_set_all_fields : Test(5) {

    my $report_info = Yahoo::Marketing::ReportInfo->new
                                                  ->createDate( 'create date' )
                                                  ->reportID( 'report id' )
                                                  ->reportName( 'report name' )
                                                  ->status( 'status' )
                   ;

    ok( $report_info );

    is( $report_info->createDate, 'create date', 'can get create date' );
    is( $report_info->reportID, 'report id', 'can get report id' );
    is( $report_info->reportName, 'report name', 'can get report name' );
    is( $report_info->status, 'status', 'can get status' );

};



1;

