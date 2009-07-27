package Chloro::Field;

use strict;
use warnings;

use Chloro::FieldTypes ();
use Chloro::Types qw( :all );
use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw( Defined Bool );

has name =>
    ( is       => 'ro',
      isa      => FieldName,
      required => 1,
    );

has label =>
    ( is      => 'ro',
      isa     => NonEmptyStr,
      lazy    => 1,
      builder => '_build_label',
    );

has help_text =>
    ( is        => 'ro',
      isa       => NonEmptyStr,
      predicate => 'has_help_text',
    );

has default =>
    ( is        => 'ro',
      isa       => Defined,
      predicate => 'has_default',
    );

has type =>
    ( is      => 'ro',
      isa     => FieldType,
      default => sub { Chloro::FieldTypes::NonEmptyStr },
      coerce  => 1,
    );

has is_required =>
    ( is       => 'ro',
      isa      => Bool,
      default  => 0,
    );

has is_boolean =>
    ( is       => 'ro',
      isa      => Bool,
      lazy     => 1,
      default  => sub { $_[0]->type()->is_a_type_of(Bool) },
      init_arg => undef,
    );

has render_as =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      default  => 'text',
    );

has html_class =>
    ( is        => 'ro',
      isa       => NonEmptyStr,
      predicate => '_has_html_class',
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

sub _build_label
{
    my $self = shift;

    return $self->_form()->style()->label_from_name( $self->name() );
}

sub value_is_valid
{
    my $self  = shift;
    my $value = shift;

    return $self->type()->check($value);
}

sub error_for_value
{
    my $self  = shift;
    my $value = shift;

    if ( $self->type()->has_message )
    {
        return
              'The '
            . $self->name()
            . ' field '
            . $self->type()->get_message($value);
    }
    else
    {
        my $field_desc
            = $self->type()->name() eq '__ANON__'
            ? 'valid'
            : 'a valid ' . $self->type()->name();

        return
              'The '
            . $self->name()
            . ' field was not '
            . $field_desc
            . " (got $value)";
    }
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
