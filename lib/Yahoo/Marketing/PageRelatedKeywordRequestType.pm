package Yahoo::Marketing::PageRelatedKeywordRequestType;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::PageRelatedKeywordRequestType - an object to represent a request for keyword suggestions based on the content of a specified web page.

=cut

sub _user_setable_attributes {
    return ( qw/ 
              excludedKeywords
              excludedPhraseFilters
              market
              maxKeywords
              negativeKeywords
              positiveKeywords
              requiredPhraseFilters
              URL
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

See L<http://ysm.techportal.searchmarketing.yahoo.com/docs/reference/dataObjects.asp> for documentation of the various data objects.


=head2 new

Creates a new instance

=cut

=head1 METHODS

=head2 get/set methods

=over 8

excludedKeywords
excludedPhraseFilters
market
maxKeywords
negativeKeywords
positiveKeywords
requiredPhraseFilters
URL

=back

=head2 get (read only) methods

=over 8


=back

=cut

