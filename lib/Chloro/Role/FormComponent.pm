package Chloro::Role::FormComponent;

use Moose::Role;

use namespace::autoclean;

use Chloro::Types qw( Str );

has name => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

1;
