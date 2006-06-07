package Yahoo::Marketing::RangeDefinitionResponseType;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use Yahoo::Marketing::ResponseStatusType;
use Yahoo::Marketing::RangeDefinitionType;
use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::RangeDefinitionResponseType - an object to represent a Yahoo Marketing RangeDefinitionResponseType.

=cut

sub _user_setable_attributes {
    return ( qw/ 
                 rangeDefinition
                 responseStatus
            /  );
}

sub _read_only_attributes {
    return ( qw/
           / );
}

__PACKAGE__->mk_accessors( __PACKAGE__->_user_setable_attributes, 
                           __PACKAGE__->_read_only_attributes
                         );

sub _new_from_hash {
    my ( $self, $hash ) = @_;

    my $obj = __PACKAGE__->new;
    foreach my $key ( keys %$hash ) {
        if ( $key eq 'responseStatus' ) {
            my $response_status_type = Yahoo::Marketing::ResponseStatusType->new->_new_from_hash( $hash->{$key} );
            $obj->$key( $response_status_type );
        }
        elsif ( $key eq 'rangeDefinition' ) {
            my @array;
            foreach my $item (ref $hash->{ $key }{'RangeDefinitionType'} eq 'ARRAY' ? @{ $hash->{ $key }{'RangeDefinitionType'} } : ( $hash->{ $key }{'RangeDefinitionType'} || () ) ) {
                my $range_definition_type = Yahoo::Marketing::RangeDefinitionType->new->_new_from_hash( $item );
                push @array, $range_definition_type;
            }
            $obj->$key( @array ? \@array : undef );
        }
        else {
            $obj->$key( $hash->{ $key } );
        }
    }
    return $obj;
}


1;
=head1 SYNOPSIS

See http://ysm.techportal.searchmarketing.yahoo.com/docs/reference/dataObjects.asp for documentation of the various data objects.


=head2 new

Creates a new instance

=cut

=head1 METHODS

=head2 get/set methods

=over 8

    rangeDefinition
    responseStatus

=back

=head2 get (read only) methods

=over 8


=back

=cut

