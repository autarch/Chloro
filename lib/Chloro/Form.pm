package Chloro::Form;

use strict;
use warnings;

use Moose;
use MooseX::SemiAffordanceAccessor;

with 'Chloro::Role::HasCollection' =>
    { container => 'form',
      thing     => 'fieldset',
      class     => 'Chloro::FieldSet',
    };

has ignore_empty_fields =>
    ( is      => 'rw',
      isa     => Bool,
      default => 1,
    );

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
