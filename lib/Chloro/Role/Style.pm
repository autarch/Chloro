package Chloro::Role::Style;

use strict;
use warnings;

use Moose::Role;

requires qw( label_from_name missing_field_error );

no Moose::Role;

1;
