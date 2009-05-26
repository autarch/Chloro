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
    as Object,
    where { $_[0]->can('check') },
    message { 'Must be a type constraint object with a check() method' };

1;
