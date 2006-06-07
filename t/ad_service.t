#!perl 
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

#use Test::More skip_all => 'AdService->addAd not working: http://tracker.corp.yahoo.com/show_bug.cgi?id=14762';

use lib 't/lib';
use Yahoo::Marketing::TEST::AdService;

#use SOAP::Lite +trace => [qw/ debug method fault /]; #global debug for SOAP calls
use SOAP::Lite +trace => [qw/ fault /]; #global debug for SOAP calls

Test::Class->runtests;

