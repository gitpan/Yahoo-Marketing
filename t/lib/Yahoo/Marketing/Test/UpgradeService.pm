package Yahoo::Marketing::Test::UpgradeService;
# Copyright (c) 2009 Yahoo! Inc.  All rights reserved.
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997)

use strict; use warnings;

use base qw/ Yahoo::Marketing::Test::PostTest /;
use Test::More;

use Yahoo::Marketing::UpgradeService;

# use SOAP::Lite +trace => [qw/ debug method fault /];

sub SKIP_CLASS {
    my $self = shift;
    # 'not running post tests' is a true value
    return 'not running post tests' unless $self->run_post_tests;
    return;
}

sub test_upgrade_service : Test(2) {
    my ( $self ) = @_;

    my $ysm_ws = Yahoo::Marketing::UpgradeService->new->parse_config( section => $self->section );
    $ysm_ws->use_location_service(0);

    my @ids = $ysm_ws->getAccountsForUpgradePreview();
    ok( @ids );

    @ids = $ysm_ws->getMasterAccountLocationForUpgradePreview();
    ok( @ids );
}

1;

