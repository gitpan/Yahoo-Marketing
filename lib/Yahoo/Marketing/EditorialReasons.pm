package Yahoo::Marketing::EditorialReasons;
# Copyright (c) 2006 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Yahoo::Marketing::ComplexType/;

=head1 NAME

Yahoo::Marketing::EditorialReasons - a base class for various EditoralReasons types.

=cut
sub _new_from_hash {
    my ( $self, $hash ) = @_;

    my $obj_type = ref $self;

    my $new_obj = $obj_type->new;

    foreach my $key ( keys %$hash ){
        if( ref $hash->{ $key } eq 'HASH' and defined $hash->{ $key }->{ int } ){
            if( ref $hash->{ $key }->{ int } eq 'ARRAY' ){
                $new_obj->$key( $hash->{ $key }->{ int } );
            }else{
                $new_obj->$key( [ $hash->{ $key }->{ int } ] );  # make it an array ref always
            }
        }else{
            $new_obj->$key( $hash->{ $key } );
        }
    }

    return $new_obj;
}

1;
=head1 SYNOPSIS

See L<http://ysm.techportal.searchmarketing.yahoo.com/docs/reference/dataObjects.asp> for documentation of the various data objects.

This module is not intended to be used directly.   Documentation for each of the complex types is in the appropriate module.  

=cut

