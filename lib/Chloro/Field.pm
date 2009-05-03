package Chloro::Field;

use strict;
use warnings;

use Moose;
use Chloro::Types;

has name =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      required => 1,
    );

has label =>
    ( is  => 'ro',
      isa => NonEmptyStr,
    );

# has type =>
#     ( is      => 'ro',
#       isa     => 'Chloro::FieldType',
#       default => Chloro::FieldType
#     );

no Moose;

__PACKAGE__->meta()->make_immutable();
