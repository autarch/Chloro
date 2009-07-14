package Chloro::Role::Error;

use strict;
use warnings;

use Chloro::Types qw( NonEmptyStr );
use Moose::Role;

has message =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      required => 1,
    );

no Moose::Role;

1;
