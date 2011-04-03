package Chloro::Error::Field;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Field;
use Chloro::Types qw( NonEmptyStr );

with 'Chloro::Role::Error';

has field => (
    is       => 'ro',
    isa      => 'Chloro::Field',
    required => 1,
);

has error => (
    is       => 'ro',
    does     => 'Chloro::Role::ErrorMessage',
    required => 1,
);

__PACKAGE__->meta()->make_immutable();

1;
