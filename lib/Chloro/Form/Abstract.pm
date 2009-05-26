package Chloro::Form::Abstract;

use strict;
use warnings;

use Carp qw( confess );
use Chloro::FieldSet::Abstract;
use Chloro::Form::Concrete;
use Moose;
use MooseX::AttributeHelpers;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw( HashRef Str );

extends 'Chloro::Form';

has '_group_names' =>
    ( metaclass => 'Collection::Hash',
      is        => 'ro',
      isa       => HashRef[Str],
      lazy      => 1,
      builder   => '_build_group_names',
      clearer   => '_clear_group_names',
      provides  => { exists => 'has_group_named' },
      init_arg  => undef,
    );

with 'Chloro::Role::HasCollection' =>
    { container => 'form',
      thing     => 'fieldset',
      class     => 'Chloro::FieldSet::Abstract',
    };

with 'Chloro::Role::Concretizes';

before add_fieldset => sub
{
    my $self = shift;
    my $fs   = shift;

    $self->_clear_group_names();

    for my $fg ( grep { ! $_->is_implicit() } $fs->groups() )
    {
        confess 'This form already has a group named ' . $fg->name()
            if $self->has_group_named( $fg->name() );
    }
};

sub _build_group_names
{
    my $self = shift;

    return { map { $_->name() => 1 }
             grep { ! $_->is_implicit() }
             map { $_->groups() }
             $self->fieldsets()
           };
}

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
