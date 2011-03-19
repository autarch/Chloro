package Chloro::Types::Internal;

use strict;
use warnings;

use MooseX::Types -declare => [
    qw(
        )
];
use MooseX::Types::Common::Numeric qw( PositiveInt );
use MooseX::Types::Common::String qw( NonEmptyStr );
use MooseX::Types::Moose qw(  Defined Int Object Str );

1;
