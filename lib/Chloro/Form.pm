package Chloro::Form;

use strict;
use warnings;

use Carp qw( croak );
use Chloro::Style::Default;
use Chloro::Types qw( :all );
use Moose;
use MooseX::Params::Validate qw( pos_validated_list );
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw( Bool );

has style =>
    ( is      => 'rw',
      does    => 'Chloro::Role::Style',
      lazy    => 1,
      default => sub { Chloro::Style::Default->new() },
    );

sub add_group
{
    my $self  = shift;
    my $group = shift;

    $self->current_fieldset()
         ->add_group($group);
}

sub add_field
{
    my $self  = shift;
    my $field = shift;

    $self->current_fieldset()
         ->current_group()
         ->add_field($field);
}

sub include_form
{
    my $self   = shift;
    my ($form) = pos_validated_list( \@_, { isa => 'Chloro::Form' } );

    $self->add_fieldset($_) for $form->fieldsets();
}

sub fields
{
    my $self = shift;

    my @fs = $self->fieldsets();
    croak 'Cannot call fields() on a form with named fieldsets'
        if @fs > 1 || ! $fs[0]->is_implicit();

    my @fg = $fs[0]->groups();

    return $fg[0]->fields();
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
