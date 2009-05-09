package Chloro::Field;

use strict;
use warnings;

use Chloro::Types qw( :all );

use Moose;
use MooseX::StrictConstructor;

has name =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      required => 1,
    );

has label =>
    ( is      => 'ro',
      isa     => NonEmptyStr,
      lazy    => 1,
      default => sub { $_[0]->name() },
    );

# has type =>
#     ( is      => 'ro',
#       isa     => 'Chloro::FieldType',
#       default => Chloro::FieldType
#     );

no Moose;

__PACKAGE__->meta()->make_immutable();
