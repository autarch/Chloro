package Chloro::Role::FormComponent;

use Moose::Role;

use namespace::autoclean;

use Chloro::Types qw( NonEmptyStr );

has name => (
    is       => 'ro',
    isa      => NonEmptyStr,
    required => 1,
);

1;
