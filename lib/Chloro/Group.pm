package Chloro::Group;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Types qw( ArrayRef CodeRef NonEmptySimpleStr Str );

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

has is_empty_checker => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    default => 'group_is_empty',
);

sub dump {
    my $self = shift;

    return (
        repetition_field => $self->repetition_field(),
        fields => { map { $_->name() => { $_->dump() } } $self->fields() },
    );
}

__PACKAGE__->meta()->make_immutable();

1;
