package Chloro::FieldGroup;

use strict;
use warnings;

use Chloro::Types qw( :all );
use MooseX::Types::Moose qw( ArrayRef Int );

use Moose;
use MooseX::AttributeHelpers;
use MooseX::StrictConstructor;

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
      default   => sub { [] },
      provides  => { elements => 'fields',
                     push => 'add_field',
                   },
    );

no Moose;

__PACKAGE__->meta()->make_immutable();
