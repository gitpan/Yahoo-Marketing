package Yahoo::Marketing::BudgetingService;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use base qw/Yahoo::Marketing::Service/;


=head1 NAME

Yahoo::Marketing::BudgetingService - an object that provides operations for setting, updating, and viewing the daily spend limits of your account and campaign budgets.

=cut

=head1 SYNOPSIS


See EWS documentation online for available SOAP methods:

http://ysm.techportal.searchmarketing.yahoo.com/docs/reference/services/BudgetingService.asp

Also see perldoc Yahoo::Marketing::Service for functionality common to all service modules.




=head2 new

Creates a new instance

=cut 

sub _add_account_to_header { return 1; } # force addition of account to header

1;
