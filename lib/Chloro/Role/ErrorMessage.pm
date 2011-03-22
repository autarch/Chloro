package Chloro::Role::ErrorMessage;

use Moose::Role;

use namespace::autoclean;

use Chloro::Types qw( NonEmptyStr );

has message => (
    is       => 'ro',
    isa      => NonEmptyStr,
    required => 1,
);

1;
