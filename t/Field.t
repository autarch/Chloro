use strict;
use warnings;

use Test::Exception;
use Test::More 'no_plan';

use Chloro::Field::Abstract;
use Chloro::FieldTypes qw( :all );
use Moose::Util::TypeConstraints;

{
    my $field = Chloro::Field::Concrete->new( name => 'foo',
                                              type => NonEmptyStr,
                                            );

    ok( $field->value_is_valid('foo'),
        'foo is valid for a NonEmptyStr field' );
    ok( $field->value_is_valid(42),
        '42 is valid for a NonEmptyStr field' );
    ok( ! $field->value_is_valid( q{} ),
        'an empty string is not valid for a NonEmptyStr field' );
    ok( ! $field->value_is_valid(undef),
        'undef string is not valid for a NonEmptyStr field' );

    is( $field->error_for_value( q{} ),
        'The foo field must not be empty',
        'error message for empty string' );
}

{
    my $field =
        Chloro::Field::Concrete->new
                ( name => 'foo',
                  type => ( subtype as 'Int' => where { $_ <= 10 } ),
                );

    ok( $field->value_is_valid(4),
        '4 is valid for field with anon subtype as type' );
    ok( ! $field->value_is_valid(11),
        '11 is valid for field with anon subtype as type' );

    is( $field->error_for_value(11),
        'The foo field was not valid (got 11)',
        'error message for subtype without a message' );

    isa_ok( $field->type(), 'Chloro::FieldType' );
}
