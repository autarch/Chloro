package Chloro::FieldSet::Concrete;

use strict;
use warnings;

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

extends 'Chloro::FieldSet';

with 'Chloro::Role::HasCollection' =>
    { container   => 'fieldset',
      thing       => 'group',
      class       => 'Chloro::FieldGroup::Concrete',
      name_method => 'unique_name',
    };

has '+form' => ( isa => 'Chloro::Form::Concrete' );

no Moose;

__PACKAGE__->meta()->make_immutable();
