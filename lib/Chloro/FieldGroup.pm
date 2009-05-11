package Chloro::FieldGroup;

use strict;
use warnings;

use Chloro::Types qw( NonEmptyStr );
use Chloro::UniqueNamedObjectArray;
use Moose;
use MooseX::AttributeHelpers;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw( Int );

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
    ( is      => 'ro',
      isa     => 'Chloro::UniqueNamedObjectArray',
      default => sub { Chloro::UniqueNamedObjectArray->new() },
      handles => { fields    => 'objects',
                   add_field => 'add_object',
                   get_field => 'get_object',
                   has_field => 'has_object',
                 },
    );

no Moose;

__PACKAGE__->meta()->make_immutable();
