package Chloro::FieldSet::Abstract;

use strict;
use warnings;

use Carp qw( croak );
use Chloro::FieldGroup::Abstract;
use Chloro::FieldSet::Concrete;
use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

extends 'Chloro::FieldSet';

with 'Chloro::Role::HasCollection' =>
    { container => 'fieldset',
      thing     => 'group',
      class     => 'Chloro::FieldGroup::Abstract',
    };

has '+form' => ( isa => 'Chloro::Form::Abstract' );

with 'Chloro::Role::Concretizes';

sub as_concrete
{
    my $self = shift;
    my %p    = @_;

    my $clone = $self->_concrete_clone();

    for my $group ( $self->groups() )
    {
        my @ids = @{ $p{repeats}{ $group->name() } || [] };

        croak 'Cannot repeat the ' . $group->name() . ' group'
            if @ids > 1 && ! $group->can_repeat();

        $clone->add_group( $group->as_concrete( repeat_id => $_ ) )
            for @ids;
    }

    return $clone;
}

no Moose;

__PACKAGE__->meta()->make_immutable();
