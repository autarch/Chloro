package Chloro::Field::Abstract;

use strict;
use warnings;

use Chloro::Field::Concrete;
use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

extends 'Chloro::Field';

has '+group' => ( isa => 'Chloro::FieldGroup::Abstract' );

has '+_form' => ( isa => 'Chloro::Form::Abstract' );

with 'Chloro::Role::Concretizes';

sub as_concrete
{
    my $self = shift;

    return $self->_concrete_clone();
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
