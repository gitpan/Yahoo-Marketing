package Yahoo::Marketing::ResponseType;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use Carp;
use Yahoo::Marketing::Error;
use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::ResponseType - an object to represent a Yahoo Marketing CampaignResponse.
A base class for the various Response complexTypes, e.g. CampaignResponse, AdGroupResponse, AdResponse, etc.

=cut


sub _type_field {
    confess "_type_field must be defined in child class!";
}

sub _editorial_reasons_class {
    confess "_editorial_reasons_class must be defined in child class!";
}



1;

=head1 SYNOPSIS

A base class for the various Response complexTypes, e.g. CampaignResponse, AdGroupResponse, AdResponse, etc.

=cut

