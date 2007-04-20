package Yahoo::Marketing::RelatedKeywordResponseType;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use Yahoo::Marketing::RelatedKeywordType;
use Yahoo::Marketing::ResponseStatusType;
use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::RelatedKeywordResponseType - an object to represent a Yahoo Marketing RelatedKeywordResponseType.

=cut

sub _user_setable_attributes {
    return ( qw/ 
                 notes
                 relatedKeywords
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
        elsif ( $key eq 'relatedKeywords' ) {
            if( $hash->{ $key } ){
                my @array;
                foreach my $item ( ref $hash->{ $key }{'RelatedKeywordType'} eq 'ARRAY' ? @{ $hash->{ $key }{'RelatedKeywordType'} } : ( $hash->{ $key }{'RelatedKeywordType'} || () ) ) {
                    my $related_keyword_type = Yahoo::Marketing::RelatedKeywordType->new->_new_from_hash( $item );
                    push @array, $related_keyword_type;
                }
                $obj->$key( @array ? \@array : [] );
            }else{
                $obj->$key( [] );
            }
        }
        elsif ( $key eq 'notes' ) {
            $obj->$key( $hash->{$key} ? $hash->{$key}->{string} : undef );
        }
        else {
            $obj->$key( $hash->{ $key } );
        }
    }
    return $obj;
}



1;
=head1 SYNOPSIS

See L<http://ysm.techportal.searchmarketing.yahoo.com/docs/reference/dataObjects.asp> for documentation of the various data objects.


=head2 new

Creates a new instance

=cut

=head1 METHODS

=head2 get/set methods

=over 8

    notes
    relatedKeywords
    responseStatus

=back

=head2 get (read only) methods

=over 8


=back

=cut

