package Chloro::Role::Result;

use Moose::Role;

use namespace::autoclean;

use Chloro::Error::Field;
use Chloro::Types qw( ArrayRef );

has _errors => (
    traits   => ['Array'],
    isa      => ArrayRef ['Chloro::Error::Field'],
    init_arg => 'errors',
    required => 1,
    handles  => {
        errors   => 'elements',
        is_valid => 'is_empty',
    },
);

1;
