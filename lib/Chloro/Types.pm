package Chloro::Types;

use strict;
use warnings;

use MooseX::Types::Moose ':all';
use MooseX::Types
    -declare => [ qw( ClassDoesImplicit
                      NonEmptyStr
                      NamedObject
                      FieldName
                      FieldType
                      NamedType
                      HTTPMethod
                      NonEmptyStr
                      PosInt
                      PosOrZeroInt
                      PosNum
                      PosOrZeroNum
                    ) ];

subtype ClassDoesImplicit,
    as Any,
    where { $_->meta()->does_role('Chloro::Role::CanBeImplicit') },
    message { "$_ does not do the Chloro::Role::CanBeImplicit role" };

subtype NonEmptyStr,
    as Str,
    where { defined && length },
    message { 'Must be a non-empty string.' };

subtype NamedObject,
    as Object,
    where { $_[0]->can('name') },
    message { 'Must be an object with a name() method' };

subtype FieldName,
    as NonEmptyStr,
    where { /^[^\.]+$/ },
    message { 'Field names cannot contain periods' };

subtype FieldType,
    as class_type('Chloro::FieldType');

coerce FieldType,
    from Str,
    via { Moose::Utils::TypeConstraint::parse_or_find_type_constraint($_) };

coerce FieldType,
    from class_type('Moose::Meta::TypeConstraint'),
    via { Chloro::FieldType->new( type => $_ ) };

subtype NamedType,
    as class_type('Moose::Meta::TypeConstraint'),
    where { $_->name() ne '__ANON__' },
    message { 'You must provide a named type' };

enum HTTPMethod, qw( GET POST PUT DELETE );

# For field types

subtype NonEmptyStr,
    as    Str,
    where { defined && length },
    message { 'must not be empty' };

subtype PosInt,
    as    Int,
    where { $_ > 0 },
    message { "must be a positive integer (got $_)" };

subtype PosOrZeroInt,
    as    Int,
    where { $_ >= 0 },
    message { "must be an integer greater than or equal to zero (got $_)" };

subtype PosNum,
    as    Num,
    where { $_ > 0 },
    message { "must be an number (got $_)" };

subtype PosOrZeroNum,
    as    Num,
    where { $_ >= 0 },
    message { "must be an number greater than or equal to zero (got $_)" };

1;
