package Chloro::Types;

use strict;
use warnings;

use MooseX::Types -declare => [ qw( ClassDoesImplicit NonEmptyStr ) ];
use MooseX::Types::Moose ':all';

subtype ClassDoesImplicit
    => as ClassName
    => where { $_->meta()->does_role('Chloro::Role::CanBeImplicit') };

subtype NonEmptyStr
    => as Str
    => where { defined && length }
    => message { 'Must be a non-empty string.' };

1;
