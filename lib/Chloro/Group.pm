package Chloro::Group;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Types qw( ArrayRef Bool Str );

with 'Chloro::Role::FormComponent';

has _fields => (
    traits   => ['Array'],
    isa      => ArrayRef ['Chloro::Field'],
    init_arg => undef,
    lazy     => 1,
    default  => sub { [] },
    handles  => {
        fields     => 'elements',
        has_fields => 'count',
    },
);

has repetition_key => (
    is        => 'ro',
    isa       => Str,
    predicate => 'is_repeatable',
);

__PACKAGE__->meta()->make_immutable();

1;
