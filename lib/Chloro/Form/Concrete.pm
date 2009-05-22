package Chloro::Form::Concrete;

use strict;
use warnings;

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

extends 'Chloro::Form';

with 'Chloro::Role::HasCollection' =>
    { container => 'form',
      thing     => 'fieldset',
      class     => 'Chloro::FieldSet::Concrete',
    };

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
