package Chloro::Error::Form;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;

with 'Chloro::Role::Error';

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
