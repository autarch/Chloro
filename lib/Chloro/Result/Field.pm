package Chloro::Result::Field;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Types qw( ArrayRef Item );

with 'Chloro::Role::Result';

has _errors => (
    traits   => ['Array'],
    isa      => ArrayRef ['Chloro::Error::Field'],
    init_arg => 'errors',
    required => 1,
    handles  => {
        errors   => 'elements',
        is_valid => 'is_empty',
    },
);

has field => (
    is       => 'ro',
    isa      => 'Chloro::Field',
    required => 1,
);

has value => (
    is        => 'ro',
    isa       => Item,
    predicate => 'has_value',
);

sub key_value_pairs {
    my $self = shift;

    return unless $self->has_value();

    return ( $self->field->name() => $self->value() );
}

__PACKAGE__->meta()->make_immutable();

1;
