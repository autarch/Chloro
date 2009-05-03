package Chloro::FieldGroup;

use strict;
use warnings;

use Moose;
use MooseX::AttributeHelpers;
use Chloro::Types;

with 'Chloro::Role::CanBeImplicit';

has name =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      required => 1,
    );

has repeat_count =>
    ( is      => 'ro',
      isa     => Int,
      default => 1,
    );

has _fields =>
    ( metaclass => 'Collection::Array',
      is        => 'ro',
      isa       => ArrayRef['Chloro::Field'],
      provides  => { push => '_add_field',
                   },
    );

no Moose;

__PACKAGE__->meta()->make_immutable();
