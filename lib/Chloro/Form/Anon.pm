package Chloro::Form::Anon;

use strict;
use warnings;

use Moose;

extends 'Chloro::Form';

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
