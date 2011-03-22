package Chloro::ResultSet;

use Moose;

use namespace::autoclean;

use Chloro::Error::Form;
use Chloro::Types qw( ArrayRef Bool );
use List::AllUtils qw( any );

with 'Chloro::Role::ResultSet';

has _form_errors => (
    traits   => ['Array'],
    isa      => ArrayRef ['Chloro::Error::Form'],
    init_arg => 'form_errors',
    required => 1,
    handles  => {
        form_errors      => 'elements',
        _has_form_errors => 'count',
    },
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

    return 0 if $self->_has_form_errors();

    return 0 if any { ! $_->is_valid() } $self->_result_values();

    return 1;
}

sub results_hash {
    my $self = shift;

    return
        map { $_->field()->name() => $_->value() }
        grep { $_->has_value() } $self->_result_values();
}

__PACKAGE__->meta()->make_immutable();

1;
