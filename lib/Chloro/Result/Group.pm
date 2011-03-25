package Chloro::Result::Group;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Error::Field;
use Chloro::Types qw( Bool NonEmptyStr );
use List::AllUtils qw( any );

with qw( Chloro::Role::Result Chloro::Role::ResultSet );

has group => (
    is       => 'ro',
    isa      => 'Chloro::Group',
    required => 1,
);

has key => (
    is       => 'ro',
    isa      => NonEmptyStr,
    required => 1,
);

has prefix => (
    is       => 'ro',
    isa      => NonEmptyStr,
    required => 1,
);

has is_valid => (
    is       => 'ro',
    isa      => Bool,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_is_valid',
);

sub _build_is_valid {
    my $self = shift;

    return 0 if any { ! $_->is_valid() } $self->_result_values();

    return 1;
}

sub key_value_pairs {
    my $self = shift;

    return map { $_->key_value_pairs() } $self->_result_values();
}

__PACKAGE__->meta()->make_immutable();

1;
