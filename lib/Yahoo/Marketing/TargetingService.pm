package Yahoo::Marketing::TargetingService;
# Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Yahoo::Marketing::Service/;


=head1 NAME

Yahoo::Marketing::TargetingService - an object that provides access to Yahoo Marketing's Targeting SOAP Service.

=cut

=head1 SYNOPSIS


See EWS documentation online for available SOAP methods:

L<http://searchmarketing.yahoo.com/developer/docs/V5/reference/services/TargetingService.php>

Also see perldoc Yahoo::Marketing::Service for functionality common to all service modules.




=head2 new

Creates a new instance

=cut 

sub _add_account_to_header { return 1; } # force addition of account to header


1;
