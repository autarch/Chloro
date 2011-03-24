package Chloro::Role::Result;

use Moose::Role;

use namespace::autoclean;

use Chloro::Error::Field;
use Chloro::Types qw( ArrayRef );

requires 'key_value_pairs';

1;
