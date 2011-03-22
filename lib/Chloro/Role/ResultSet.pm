package Chloro::Role::ResultSet;

use Moose::Role;

use namespace::autoclean;

use Chloro::Types qw( HashRef Result );

has _results => (
    traits   => ['Hash'],
    isa      => HashRef [Result],
    init_arg => 'results',
    required => 1,
    handles  => {
        results        => 'elements',
        result_for     => 'get',
        _result_values => 'values',
    },
);

1;
