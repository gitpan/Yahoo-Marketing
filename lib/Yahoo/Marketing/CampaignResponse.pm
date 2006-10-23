package Yahoo::Marketing::CampaignResponse;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use Yahoo::Marketing::Error;
use base qw/Yahoo::Marketing::ResponseType/;

=head1 NAME

Yahoo::Marketing::CampaignResponse - an object to represent a Yahoo Marketing CampaignResponse.

=cut

sub _user_setable_attributes {
    return ( qw/ 
                 campaign
                 errors
                 operationSucceeded
            /  );
}

sub _read_only_attributes {
    return ( qw/
           / );
}

sub _type_field {
    return 'campaign';
}

__PACKAGE__->mk_accessors( __PACKAGE__->_user_setable_attributes, 
                           __PACKAGE__->_read_only_attributes
                         );




1;
=head1 SYNOPSIS

See L<http://ysm.techportal.searchmarketing.yahoo.com/docs/reference/dataObjects.asp> for documentation of the various data objects.


=cut

=head1 METHODS

=head2 new

Creates a new instance

=head2 get/set methods

=over 8

    campaign
    errors
    operationSucceeded

=back

=head2 get (read only) methods

=over 8


=back

=cut

