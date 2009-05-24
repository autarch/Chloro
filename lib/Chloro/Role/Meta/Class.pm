package Chloro::Role::Meta::Class;

use strict;
use warnings;

use Chloro::Form::Abstract;
use Moose::Role;

has form =>
    ( is      => 'ro',
      isa     => 'Chloro::Form::Abstract',
      default => sub { Chloro::Form::Abstract->new() },
    );


no Moose::Role;

1;
