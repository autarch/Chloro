package Chloro::ErrorMessage::Missing;

use Moose;

use namespace::autoclean;

with 'Chloro::Role::ErrorMessage';

__PACKAGE__->meta()->make_immutable();

1;
