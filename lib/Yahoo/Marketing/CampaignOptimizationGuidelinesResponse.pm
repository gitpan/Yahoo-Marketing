package Yahoo::Marketing::CampaignOptimizationGuidelinesResponse;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use Yahoo::Marketing::CampaignOptimizationGuidelines;
use Yahoo::Marketing::Error;
use base qw/Yahoo::Marketing::ResponseType/;

=head1 NAME

Yahoo::Marketing::CampaignOptimizationGuidelinesResponse - an object to represent a Yahoo Marketing CampaignOptimizationGuidelinesResponse.

=cut

sub _user_setable_attributes {
    return ( qw/ 
                 campaignOptimizationGuidelines
                 errors
                 operationSucceeded
            /  );
}

sub _read_only_attributes {
    return ( qw/
           / );
}

__PACKAGE__->mk_accessors( __PACKAGE__->_user_setable_attributes, 
                           __PACKAGE__->_read_only_attributes
                         );

sub _type_field {
    return 'campaignOptimizationGuidelines';
}


1;
=head1 SYNOPSIS

See L<http://ysm.techportal.searchmarketing.yahoo.com/docs/reference/dataObjects.asp> for documentation of the various data objects.


=cut

=head1 METHODS

=head2 new

Creates a new instance

=head2 get/set methods

=over 8

    campaignOptimizationGuidelines
    errors
    operationSucceeded

=back

=head2 get (read only) methods

=over 8


=back

=cut
