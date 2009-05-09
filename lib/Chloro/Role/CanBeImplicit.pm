package Chloro::Role::CanBeImplicit;

use strict;
use warnings;

use MooseX::Types::Moose qw( Bool );

use Moose::Role;

has is_implicit =>
    ( is      => 'ro',
      isa     => Bool,
      default => 0,
    );

no Moose::Role;

1;

