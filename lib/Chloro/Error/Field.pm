package Chloro::Error::Field;

use Moose;

use namespace::autoclean;

use Chloro::Field;
use Chloro::Types qw( NonEmptyStr );

has field => (
    is       => 'ro',
    isa      => 'Chloro::Field',
    required => 1,
    weak_ref => 1,
);

has error => (
    is       => 'ro',
    does     => 'Chloro::Role::ErrorMessage',
    required => 1,
);

__PACKAGE__->meta()->make_immutable();

1;
