package Chloro::Role::Trait::HasFormComponents;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.07';

use Moose::Role;

use Carp qw( croak );
use Tie::IxHash;

has _fields => (
    isa      => 'Tie::IxHash',
    init_arg => undef,
    default  => sub { Tie::IxHash->new() },
    handles  => {
        _add_field   => 'STORE',
        has_field    => 'EXISTS',
        get_field    => 'FETCH',
        local_fields => 'Values',
    },
);

has _groups => (
    isa      => 'Tie::IxHash',
    init_arg => undef,
    default  => sub { Tie::IxHash->new() },
    handles  => {
        _add_group   => 'STORE',
        has_group    => 'EXISTS',
        local_groups => 'Values',
    },
);

sub add_field {
    my $self  = shift;
    my $field = shift;

    if ( $self->has_field( $field->name() ) ) {
        my $name = $field->name();
        croak "Cannot add two fields with the same name ($name)";
    }

    if ( $self->has_group( $field->name() ) ) {
        my $name = $field->name();
        croak "Cannot share a name between a field and a group ($name)";
    }

    $self->_add_field( $field->name() => $field );

    return;
}

sub add_group {
    my $self  = shift;
    my $group = shift;

    if ( $self->has_group( $group->name() ) ) {
        my $name = $group->name();
        croak "Cannot add two groups with the same name ($name)";
    }

    if ( $self->has_field( $group->name() ) ) {
        my $name = $group->name();
        croak "Cannot share a name between a field and a group ($name)";
    }

    $self->_add_group( $group->name() => $group );

    return;
}

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _make_field {
    my $self = shift;

    return Chloro::Field->new(
        name => shift,
        @_,
    );
}
## use critic

1;

# ABSTRACT: A metaclass trait for classes and roles which use Chloro

__END__

=for Pod::Coverage add_field add_group

=head1 DESCRIPTION

This trait adds meta-information to classes and traits which C<use Chloro>.

=cut
