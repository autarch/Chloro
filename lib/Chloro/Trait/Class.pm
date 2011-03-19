package Chloro::Trait::Class;

use Moose::Role;

use namespace::autoclean;

use Carp qw( croak );
use Tie::IxHash;

has _fields => (
    isa      => 'Tie::IxHash',
    init_arg => undef,
    default  => sub { Tie::IxHash->new() },
    handles  => {
        _add_field => 'STORE',
        _has_field => 'EXISTS',
        fields     => 'Values',
    },
);

sub add_field {
    my $self  = shift;
    my $field = shift;

    if ( $self->_has_field( $field->name() ) ) {
        my $name = $field->name();
        croak "Cannot add two fields with the same name ($name)";
    }

    $self->_add_field( $field->name() => $field );

    return;
}

1;
