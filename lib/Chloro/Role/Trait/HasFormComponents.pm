package Chloro::Role::Trait::HasFormComponents;

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

has _groups => (
    isa      => 'Tie::IxHash',
    init_arg => undef,
    default  => sub { Tie::IxHash->new() },
    handles  => {
        _add_group => 'STORE',
        _has_group => 'EXISTS',
        groups     => 'Values',
    },
);

sub add_field {
    my $self  = shift;
    my $field = shift;

    if ( $self->_has_field( $field->name() ) ) {
        my $name = $field->name();
        croak "Cannot add two fields with the same name ($name)";
    }

    if ( $self->_has_group( $field->name() ) ) {
        my $name = $field->name();
        croak "Cannot share a name between a field and a group ($name)";
    }

    $self->_add_field( $field->name() => $field );

    return;
}

sub add_group {
    my $self  = shift;
    my $group = shift;

    if ( $self->_has_group( $group->name() ) ) {
        my $name = $group->name();
        croak "Cannot add two groups with the same name ($name)";
    }

    if ( $self->_has_field( $group->name() ) ) {
        my $name = $group->name();
        croak "Cannot share a name between a field and a group ($name)";
    }

    $self->_add_group( $group->name() => $group );

    return;
}

1;
