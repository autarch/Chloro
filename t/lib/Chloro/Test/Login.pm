package Chloro::Test::Login;

use Chloro;
use Chloro::Types qw( Bool Str );

field username => (
    isa      => Str,
    required => 1,
);

field password => (
    isa      => Str,
    required => 1,
    secure   => 1,
);

field remember => (
    isa => Bool,
);

__PACKAGE__->meta()->make_immutable;