package Chloro::FieldType;

use strict;
use warnings;

use Chloro::Types qw( NamedType );

use Moose;
use Moose::Util::TypeConstraints qw( find_type_constraint );
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

has type =>
    ( is       => 'rw',
      isa      => 'Moose::Meta::TypeConstraint',
      handles  => qr/.+/,
      required => 1,
      writer   => '_set_type',
    );

sub STORABLE_freeze
{
    my $self = shift;
    my $cloning = shift;

    return if $cloning;

    return $self->type()->name();
}

sub STORABLE_thaw
{
    my $self    = shift;
    my $cloning = shift;
    my $name    = shift;

    return if $cloning;

    $self->_set_type( find_type_constraint($name) );
}

no Moose;
no Moose::Util::TypeConstraints;

__PACKAGE__->meta()->make_immutable();

1;

