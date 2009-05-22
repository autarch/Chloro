package Chloro::Error;

use strict;
use warnings;

use Chloro::Types qw( :all );
use Moose;
use MooseX::StrictConstructor;

has field =>
    ( is       => 'ro',
      isa      => 'Chloro::Field',
      required => 1,
    );

has message =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      required => 1,
    );

no Moose;

__PACKAGE__->meta()->make_immutable();
