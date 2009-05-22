package Chloro::Field;

use strict;
use warnings;

use Chloro::Types qw( :all );
use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw( Bool Str );

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

has type =>
    ( is      => 'ro',
      isa     => ValidFieldType,
      default => sub { Str },
    );

has is_required =>
    ( is       => 'ro',
      isa      => Bool,
      default  => 0,
    );

has group =>
    ( is       => 'rw',
      isa      => 'Chloro::FieldGroup',
      weak_ref => 1,
      init_arg => undef,
    );

has _form =>
    ( is       => 'ro',
      isa      => 'Chloro::Form',
      weak_ref => 1,
      lazy     => 1,
      builder  => '_build_form',
      init_arg => undef,
    );

sub _build_form
{
    my $self = shift;

    my $group = $self->group()
        or return;

    my $fs = $group->fieldset()
        or return;

    return $fs->form();
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
