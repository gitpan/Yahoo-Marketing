package Yahoo::Marketing::Test::BulkService;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997)

use strict; use warnings;

use base qw/ Test::Class Yahoo::Marketing::Test::PostTest /;
use Test::More;

use Yahoo::Marketing::BulkService;
use Data::Dumper;

# use SOAP::Lite +trace => [qw/ debug method fault /];

sub SKIP_CLASS {
    my $self = shift;
    # 'not running post tests' is a true value
    return 'not running post tests' unless $self->run_post_tests;
    return;
}

sub test_bulk_service : Test(1) {
    my ( $self ) = @_;

    my $ysm_ws = Yahoo::Marketing::BulkService->new->parse_config( section => $self->section );

    my $id = $ysm_ws->downloadBulkTemplate( fileType => 'TSV' );
    ok( $id, 'can call downloadBulkTemplate' );

}


1;
