package Chloro::Test::Address;

use Chloro;
use Chloro::Types qw( Bool Str );

group address => (
    repetition_key => 'address_id',

    field street1 => (
        isa      => Str,
        required => 1,
    ),

    field city => (
        isa      => Str,
        required => 1,
    ),

    field state => (
        isa      => Str,
        required => 1,
    ),

    field is_preferred => (
        isa     => Bool,
        default => 0,
    ),
);

__PACKAGE__->meta()->make_immutable;
