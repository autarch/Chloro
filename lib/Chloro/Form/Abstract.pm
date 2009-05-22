package Chloro::Form::Abstract;

use strict;
use warnings;

use Chloro::FieldSet::Abstract;
use Chloro::Form::Concrete;
use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

extends 'Chloro::Form';

with 'Chloro::Role::HasCollection' =>
    { container => 'form',
      thing     => 'fieldset',
      class     => 'Chloro::FieldSet::Abstract',
    };

with 'Chloro::Role::Concretizes';

sub as_concrete
{
    my $self = shift;

    my $clone = $self->_concrete_clone();
    $clone->add_fieldset( $_->as_concrete(@_) ) for $self->fieldsets();

    return $clone;
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
