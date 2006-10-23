package Yahoo::Marketing::KeywordService;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Yahoo::Marketing::Service/;


=head1 NAME

Yahoo::Marketing::KeywordService - an object that provides access to Yahoo Marketing's Keyword SOAP Service.

=cut

=head1 SYNOPSIS


See EWS documentation online for available SOAP methods:

L<http://ysm.techportal.searchmarketing.yahoo.com/docs/reference/services/KeywordService.asp>

Also see perldoc Yahoo::Marketing::Service for functionality common to all service modules.




=head2 new

Creates a new instance

=cut 




sub _add_account_to_header { return 1; } # force addition of account to header

1;
