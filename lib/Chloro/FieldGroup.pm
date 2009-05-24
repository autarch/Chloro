package Chloro::FieldGroup;

use strict;
use warnings;

use Chloro::Field;
use Chloro::Types qw( NonEmptyStr );
use Chloro::UniqueNamedObjectArray;
use Moose;
use MooseX::AttributeHelpers;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw( Bool );

with 'Chloro::Role::CanBeImplicit';

has name =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      required => 1,
    );

has can_repeat =>
    ( is      => 'ro',
      isa     => Bool,
      lazy    => 1,
      default => sub { $_[0]->is_implicit() ? 0 : 1 } ,
    );

has _form =>
    ( is       => 'ro',
      isa      => 'Chloro::Form',
      weak_ref => 1,
      lazy     => 1,
      builder  => '_build_form',
      init_arg => undef,
    );

has _fields =>
    ( is       => 'ro',
      isa      => 'Chloro::UniqueNamedObjectArray',
      default  => sub { Chloro::UniqueNamedObjectArray->new() },
      handles  => { fields    => 'objects',
                    add_field => 'add_object',
                    get_field => 'get_object',
                    has_field => 'has_object',
                  },
      init_arg => undef,
    );

has fieldset =>
    ( is       => 'rw',
      isa      => 'Chloro::FieldSet',
      weak_ref => 1,
      init_arg => undef,
    );

after add_field => sub
{
    my $self  = shift;
    my $field = shift;

    $field->set_group($self);
};

sub _build_form
{
    my $self = shift;

    my $fs = $self->fieldset()
        or return;

    return $fs->form();
}

no Moose;

__PACKAGE__->meta()->make_immutable();
