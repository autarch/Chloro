package Chloro::Error::Field;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;

with 'Chloro::Role::Error';

has field =>
    ( is       => 'ro',
      isa      => 'Chloro::Field',
      required => 1,
    );

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
