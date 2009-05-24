package Chloro::FieldGroup::Concrete;

use strict;
use warnings;

use Carp qw( croak );
use Chloro::Types qw( NonEmptyStr );
use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw( Str );

extends 'Chloro::FieldGroup';

has name =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      lazy     => 1,
      builder  => '_build_name',
      init_arg => undef,
    );

has '+_form' => ( isa => 'Chloro::Form::Concrete' );

has base_name =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      required => 1,
    );

has repeat_id =>
    ( is      => 'ro',
      isa     => Str,
      default => q{},
    );

has '+fieldset' => ( isa => 'Chloro::FieldSet::Concrete' );


sub BUILD
{
    my $self = shift;

    if (    $self->is_implicit()
         && ! length $self->repeat_id() )
    {
        local $Carp::CarpLevel = $Carp::CarpLevel + 1;
        croak "Cannot create a named concrete group without a reapeat_id";
    }
}

sub _build_name
{
    my $self = shift;

    return '__IMPLICIT__' if $self->is_implicit();

    return join q{.}, $self->base_name(), $self->repeat_id();
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;