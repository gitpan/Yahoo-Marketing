package Yahoo::Marketing::Test::TargetingAttributeValue;
# Copyright (c) 2007 Yahoo! Inc.  All rights reserved.  
# The copyrights to the contents of this file are licensed under the Perl Artistic License (ver. 15 Aug 1997) 

use strict; use warnings;

use base qw/Test::Class/;
use Test::More;

use Yahoo::Marketing::TargetingAttributeValue;

sub test_can_create_targeting_attribute_value_and_set_all_fields : Test(5) {

    my $targeting_attribute_value = Yahoo::Marketing::TargetingAttributeValue->new
                                                                             ->ID( 'id' )
                                                                             ->description( 'description' )
                                                                             ->name( 'name' )
                                                                             ->type( 'type' )
                   ;

    ok( $targeting_attribute_value );

    is( $targeting_attribute_value->ID, 'id', 'can get id' );
    is( $targeting_attribute_value->description, 'description', 'can get description' );
    is( $targeting_attribute_value->name, 'name', 'can get name' );
    is( $targeting_attribute_value->type, 'type', 'can get type' );

};



1;

