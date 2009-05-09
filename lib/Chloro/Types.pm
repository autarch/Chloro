package Chloro::Types;

use strict;
use warnings;

use MooseX::Types::Moose ':all';
use MooseX::Types
    -declare => [ qw( ClassDoesImplicit NonEmptyStr ) ];

subtype ClassDoesImplicit,
    as Any,
    where { $_->meta()->does_role('Chloro::Role::CanBeImplicit') },
    message { "$_ does not do the Chloro::Role::CanBeImplicit role" };

subtype NonEmptyStr,
    as Str,
    where { defined && length },
    message { 'Must be a non-empty string.' };

1;
