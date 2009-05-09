package Chloro::Role::Meta::Class;

use strict;
use warnings;

use Chloro::Form;
use Moose::Role;

has form =>
    ( is      => 'ro',
      isa     => 'Chloro::Form',
      default => sub { Chloro::Form->new() },
    );


sub add_fieldset
{
    my $self     = shift;
    my $fieldset = shift;

    $self->form()
         ->add_fieldset($fieldset);
}

sub add_field_group
{
    my $self  = shift;
    my $group = shift;

    $self->form()
         ->current_fieldset()
         ->add_field_group($group);
}

sub add_field
{
    my $self  = shift;
    my $field = shift;

    $self->form()
         ->current_fieldset()
         ->current_group()
         ->add_field($field);
}

no Moose::Role;

1;
