#!perl 
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use lib 't/lib';
use Yahoo::Marketing::TEST::CampaignService;

#use SOAP::Lite +trace => [qw/ debug method fault /]; #global debug for SOAP calls

Test::Class->runtests;

