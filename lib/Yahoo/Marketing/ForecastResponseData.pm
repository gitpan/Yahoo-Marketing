package Yahoo::Marketing::ForecastResponseData;
# Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::ForecastResponseData - an object to represent a Yahoo Marketing ForecastResponseData.

=cut

sub _user_setable_attributes {
    return ( qw/ 
                 averagePosition
                 clicks
                 costPerClick
                 impressions
                 maxBid
                 missedClicks
            /  );
}

sub _read_only_attributes {
    return ( qw/
           / );
}

__PACKAGE__->mk_accessors( __PACKAGE__->_user_setable_attributes, 
                           __PACKAGE__->_read_only_attributes
                         );


1;
=head1 SYNOPSIS

See L<http://searchmarketing.yahoo.com/developer/docs/V5/reference/dataObjects.php> for documentation of the various data objects.


=cut

=head1 METHODS

=head2 new

Creates a new instance

=head2 get/set methods

=over 8

    averagePosition
    clicks
    costPerClick
    impressions
    maxBid
    missedClicks

=back

=head2 get (read only) methods

=over 8


=back

=cut

