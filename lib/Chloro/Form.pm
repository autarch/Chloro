package Chloro::Form;

use strict;
use warnings;

use Chloro::FieldSet;
use Chloro::Types qw( :all );
use MooseX::Types::Moose qw( Bool );

use Moose;
use MooseX::SemiAffordanceAccessor;

with 'MooseX::Clone';

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


sub add_field_group
{
    my $self  = shift;
    my $group = shift;

    $self->current_fieldset()
         ->add_field_group($group);
}

sub add_field
{
    my $self  = shift;
    my $field = shift;

    $self->current_fieldset()
         ->current_group()
         ->add_field($field);
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
