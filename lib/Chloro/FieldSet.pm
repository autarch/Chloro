package Chloro::FieldSet;

use strict;
use warnings;

use Carp qw( croak );
use Chloro::FieldGroup;
use Chloro::Types qw( :all );
use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

with 'Chloro::Role::CanBeImplicit';

has name =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      required => 1,
    );

has form =>
    ( is       => 'rw',
      isa      => 'Chloro::Form',
      weak_ref => 1,
      init_arg => undef,
    );

sub fields
{
    my $self = shift;

    my @fg = $self->groups();
    croak 'Cannot call fields() on a fieldset with named field groups'
        if @fg > 1 || ! $fg[0]->is_implicit();

    return $fg[0]->fields();
}

no Moose;

__PACKAGE__->meta()->make_immutable();
