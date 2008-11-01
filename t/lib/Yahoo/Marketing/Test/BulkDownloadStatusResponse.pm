package Yahoo::Marketing::Test::BulkDownloadStatusResponse;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::BulkDownloadStatusResponse;

sub test_can_create_bulk_download_status_response_and_set_all_fields : Test(3) {

    my $bulk_download_status_response = Yahoo::Marketing::BulkDownloadStatusResponse->new
                                                                                    ->downloadUrl( 'download url' )
                                                                                    ->status( 'status' )
                   ;

    ok( $bulk_download_status_response );

    is( $bulk_download_status_response->downloadUrl, 'download url', 'can get download url' );
    is( $bulk_download_status_response->status, 'status', 'can get status' );

};



1;
