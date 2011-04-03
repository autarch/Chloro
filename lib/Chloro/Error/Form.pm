package Chloro::Error::Form;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Field;

with 'Chloro::Role::Error';

has error => (
    is       => 'ro',
    does     => 'Chloro::Role::ErrorMessage',
    required => 1,
);

__PACKAGE__->meta()->make_immutable();

1;
