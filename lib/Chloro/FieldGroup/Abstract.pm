package Chloro::FieldGroup::Abstract;

use strict;
use warnings;

use Carp qw( croak );
use Chloro::Field::Abstract;
use Chloro::FieldGroup::Concrete;
use Chloro::Types qw( NonEmptyStr );
use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

extends 'Chloro::FieldGroup';

has name =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      required => 1,
    );

has '+_form' => ( isa => 'Chloro::Form::Abstract' );

has '+fieldset' => ( isa => 'Chloro::FieldSet::Abstract' );

with 'Chloro::Role::Concretizes' => { name_map => { name => 'base_name' } };

sub BUILD
{
    my $self = shift;

    if (    $self->is_implicit()
         && $self->can_repeat() )
    {
        local $Carp::CarpLevel = $Carp::CarpLevel + 1;
        croak "Cannot repeat an implicit group";
    }
}

sub as_concrete
{
    my $self = shift;

    my $clone = $self->_concrete_clone(@_);
    $clone->add_field( $_->as_concrete() ) for $self->fields();

    return $clone;
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
