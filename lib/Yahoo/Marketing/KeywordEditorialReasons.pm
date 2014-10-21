package Yahoo::Marketing::KeywordEditorialReasons;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997)

use strict; use warnings;

use base qw/Yahoo::Marketing::EditorialReasons/;

=head1 NAME

Yahoo::Marketing::KeywordEditorialReasons - an object contains the specific reason code related to an editorial annotation of an keyword.

=cut

sub _user_setable_attributes {
    return ( qw/
           /);
}

sub _read_only_attributes {
    return ( qw/
                  alternateTextEditorialReasons
                  keywordEditorialReasons
                  keywordID
                  phraseSearchTextEditorialReasons
                  textEditorialReasons
                  urlContentEditorialReasons
                  urlEditorialReasons
                  urlStringEditorialReasons
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

    alternateTextEditorialReasons
    keywordEditorialReasons
    keywordID
    phraseSearchTextEditorialReasons
    textEditorialReasons
    urlContentEditorialReasons
    urlEditorialReasons
    urlStringEditorialReasons

=back

=head2 get (read only) methods

=over 8


=back

=cut
