package Chloro::Role::Meta::Class;

use strict;
use warnings;

use Chloro::Form;
use Moose::Role;

has form =>
    ( is      => 'ro',
      isa     => 'Chloro::Form',
      default => sub { Chloro::Form->new() },
    );


no Moose::Role;

1;
