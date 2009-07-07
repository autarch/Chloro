package Chloro::FieldTypes;

use strict;
use warnings;

use MooseX::Types
    -declare => [ qw( NonEmptyStr PosInt PosOrZeroInt PosNum PosOrZeroNum ) ];

use MooseX::Types::Moose qw( Str Int Num );

subtype NonEmptyStr,
    as    Str,
    where { defined && length },
    message { 'must not be empty' };

subtype PosInt,
    as    Int,
    where { $_ > 0 },
    message { "must be an integer (got $_)" };

subtype PosOrZeroInt,
    as    Int,
    where { $_ >= 0 },
    message { "must be an integer greater than or equal to zero (got $_)" };

subtype PosNum,
    as    Num,
    where { $_ > 0 },
    message { "must be an number (got $_)" };

subtype PosOrZeroNum,
    as    Num,
    where { $_ >= 0 },
    message { "must be an number greater than or equal to zero (got $_)" };

1;
