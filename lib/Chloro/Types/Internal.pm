package Chloro::Types::Internal;

use strict;
use warnings;

use MooseX::Types -declare => [
    qw(
        Result
        )
];

role_type Result, { role => 'Chloro::Role::Result' };

1;
