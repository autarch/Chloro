package Chloro::Role::Meta::Class;

use strict;
use warnings;

use Moose::Role;
use MooseX::SemiAffordanceAccessor;

has form =>
    ( is      => 'ro',
      isa     => 'Chloro::Form'
      default => sub { Chloro::Form->new() },
    );

no Moose::Role;

1;
