package Chloro::Group;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Types qw( ArrayRef CodeRef Str );
use List::AllUtils qw( all );

with 'Chloro::Role::FormComponent';

has _fields => (
    traits   => ['Array'],
    isa      => ArrayRef ['Chloro::Field'],
    init_arg => 'fields',
    required => 1,
    handles  => {
        fields     => 'elements',
        has_fields => 'count',
    },
);

has repetition_field => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

my $_is_empty_checker = sub {
    my $self   = shift;
    my $params = shift;
    my $prefix = shift;
    my $form   = shift;

    return all { defined $params->{$_} && length $params->{$_} }
    map { join q{.}, $prefix, $_->name() } $self->fields();
};

has is_empty_checker => (
    is      => 'ro',
    isa     => CodeRef,
    default => sub {$_is_empty_checker},
);

sub has_data_in_params {
    my $self   = shift;
    my $params = shift;
    my $prefix = shift;
    my $form   = shift;

    return $self->is_empty_checker()->( $self, $params, $prefix, $form );
}

sub dump {
    my $self = shift;

    return (
        repetition_field => $self->repetition_field(),
        fields => { map { $_->name() => { $_->dump() } } $self->fields() },
    );
}

__PACKAGE__->meta()->make_immutable();

1;
