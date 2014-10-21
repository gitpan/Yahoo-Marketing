package Yahoo::Marketing::Capability;
# Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::Capability - an object to represent a group of operations that a user can execute based on their assigned role within the system. Each role has a set of defined capabilities.

=cut

sub _user_setable_attributes {
    return ( qw/ 
            /  );
}

sub _read_only_attributes {
    return ( qw/
               description
               name
           / );
}

__PACKAGE__->mk_accessors( __PACKAGE__->_user_setable_attributes, 
                           __PACKAGE__->_read_only_attributes
                         );


1;
=head1 SYNOPSIS

See L<http://searchmarketing.yahoo.com/developer/docs/V5/reference/dataObjects.php> for documentation of the various data objects.


=head2 new

Creates a new instance

=cut

=head1 METHODS

=head2 get/set methods

=over 8

=back

=head2 get (read only) methods

=over 8

description
name

=back

=cut

