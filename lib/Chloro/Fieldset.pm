package Chloro::Fieldset;

use strict;
use warnings;

use Moose;
use Chloro::Types;

with 'Chloro::Role::HasCollection' =>
    { container => 'fieldset',
      thing     => 'group',
      class     => 'Chloro::FieldGroup',
    };

has name =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      required => 1,
    );

has is_implicit =>
    ( is      => 'ro',
      isa     => Bool,
      default => 0,
    );

no Moose;

__PACKAGE__->meta()->make_immutable();
