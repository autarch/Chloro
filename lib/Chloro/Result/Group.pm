package Chloro::Result::Group;

use Moose;

use namespace::autoclean;

use Chloro::Error::Field;
use Chloro::Types qw( Str );

with qw( Chloro::Role::Result Chloro::Role::ResultSet );

has key => (
    is        => 'ro',
    isa       => Str,
    predicate => 'has_key',
);

__PACKAGE__->meta()->make_immutable();

1;
