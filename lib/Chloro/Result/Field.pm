package Chloro::Result::Field;

use Moose;

use namespace::autoclean;

use Chloro::Error::Field;
use Chloro::Types qw( ArrayRef Item );

with 'Chloro::Role::Result';

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

__PACKAGE__->meta()->make_immutable();

1;
