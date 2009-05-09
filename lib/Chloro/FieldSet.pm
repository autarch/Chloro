package Chloro::FieldSet;

use strict;
use warnings;

use Chloro::FieldGroup;
use Chloro::Types qw( :all );

use Moose;
use MooseX::StrictConstructor;


with 'Chloro::Role::CanBeImplicit';

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

no Moose;

__PACKAGE__->meta()->make_immutable();
