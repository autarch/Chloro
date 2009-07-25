package Chloro::Object;

use strict;
use warnings;

use Chloro::Error::Field;
use Chloro::Error::Form;
use Chloro::Style::Default;
use Chloro::Types qw( :all );
use Moose;
use Moose::Util::TypeConstraints qw( class_type role_type );
use MooseX::AttributeHelpers;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw( Bool ArrayRef HashRef );

has _params =>
    ( metaclass => 'Collection::Hash',
      is        => 'ro',
      isa       => HashRef,
      default   => sub { {} },
      init_arg  => 'params',
      provides  => { get => 'param',
                   },
    );

has form =>
    ( is       => 'rw',
      writer   => '_set_form',
      isa      => 'Chloro::Form::Concrete',
      handles  => [ qw( fieldsets fields style ) ],
      init_arg => undef,
    );

has action =>
    ( is       => 'rw',
      isa      => NonEmptyStr,
      required => 1,
    );

has method =>
    ( is      => 'rw',
      isa     => HTTPMethod,
      default => 'POST',
    );

has validate_empty_fields =>
    ( is      => 'ro',
      isa     => Bool,
      default => 0,
    );

has _errors =>
    ( metaclass => 'Collection::Array',
      is        => 'ro',
      isa       => ArrayRef[ role_type('Chloro::Role::Error') ],
      lazy      => 1,
      builder   => '_build_errors',
      init_arg  => undef,
      provides  => { push     => '_add_error',
                     empty    => 'has_errors',
                   },
    );

has _form_errors =>
    ( metaclass => 'Collection::Array',
      is        => 'ro',
      isa       => ArrayRef[ class_type('Chloro::Error::Form') ],
      lazy      => 1,
      builder   => '_build_form_errors',
      init_arg  => undef,
      provides  => { elements => 'form_errors',
                   },
    );

has _field_errors =>
    ( is        => 'ro',
      isa       => HashRef[ ArrayRef[ class_type('Chloro::Error::Field') ] ],
      lazy      => 1,
      builder   => '_build_field_errors',
      init_arg  => undef,
    );

sub BUILD
{
    my $self = shift;
    my $p    = shift;

    $self->_set_form( $self->meta()->form()->as_concrete( repeats => delete $p->{repeats} ) );

    return;
}

# Don't want to have subclasses inheirt this.
my $string_is_empty = sub { ! ( defined $_[0] && length $_[0] ) };
sub _delete_empty_fields
{
    my $class  = shift;
    my $params = shift;

    for my $key ( keys %{ $params } )
    {
        delete $params->{$key} if $string_is_empty->( $params->{$key} );
    }

    return;
}

sub is_valid
{
    my $self = shift;

    return ! $self->has_errors();
}

sub _build_errors
{
    my $self = shift;

    my @errors;

    my $params = $self->_params();

 FS:
    for my $fs ( $self->form()->fieldsets() )
    {
    FG:
        for my $fg ( $fs->groups() )
        {
            my @fields = $fg->fields();

            my @empty;
            my @non_empty;

            for my $field (@fields)
            {
                if ( $self->_field_is_empty($field) )
                {
                    push @empty, $field;
                }
                else
                {
                    push @non_empty, $field;
                }
            }

            # If an entire repeatable group is empty (ignoring
            # booleans, which always have a valid value), we just
            # ignore the group.
            next FG if $fg->can_repeat() && @empty == grep { ! $_->is_boolean() } @fields;

            push @errors,
                map { $self->_make_error( field   => $_,
                                          message => $self->style()->missing_field_error($_),
                                        ) }
                grep { $_->is_required() }
                    @empty;

            for my $field (@non_empty)
            {
                my $value = $self->_params->{ $field->html_name() };

                next if $field->value_is_valid($value);

                push @errors,
                    $self->_make_error( field   => $field,
                                        message => $field->error_for_value($value),
                                      );
            }
        }
    }

    return \@errors;
}

sub add_error
{
    my $self = shift;

    if ( blessed $_[0] )
    {
        $self->_add_error( $_[0] );
    }
    else
    {
        $self->_add_error( $self->_make_error(@_) );
    }
}

sub _make_error
{
    my $self = shift;
    my %p    = @_;

    if ( $p{field} )
    {
        return Chloro::Error::Field->new(%p);
    }
    else
    {
        return Chloro::Error::Form->new(%p);
    }
}

sub _build_form_errors
{
    my $self = shift;

    return [ grep { $_->isa('Chloro::Error::Form') } @{ $self->_errors() } ];
}

sub _build_field_errors
{
    my $self = shift;

    my $fe = {};

    for my $e ( grep { $_->isa('Chloro::Error::Field') } @{ $self->_errors() } )
    {
        push @{ $fe->{ $e->field()->html_name() } }, $e;
    }

    return $fe;
}

sub errors_for_field
{
    my $self  = shift;
    my $field = shift;

    return @{ $self->_field_errors()->{ $field->html_name() } || [] };
}

sub _field_is_empty
{
    my $self  = shift;
    my $field = shift;

    return 0 if $field->is_boolean();

    my $val = $self->_params()->{ $field->html_name() };

    return ! ( defined $val && length $val );
}

sub all_params
{
    my $self = shift;

    return %{ $self->_params() };
}

sub params_for_fieldset
{
    my $self = shift;
    my $name = shift;

    my $fs = $self->form()->get_fieldset($name)
        or return;

    my @fg = $fs->groups();
    if ( @fg > 1 || ! $fg[0]->is_implicit() )
    {
        confess "Cannot call params_for_fieldset on a fieldset ($name) with named groups";
    }

    return map { $_ => $self->_params()->{$_} } map { $_->html_name() } $fg[0]->fields();
}

sub params_for_group
{
    my $self = shift;
    my $name = shift;

    my @fg = grep { $_->base_name() eq $name } map { $_->groups() } $self->form()->fieldsets();
    return unless @fg;

    my $params = $self->_params();

    my %p;
    for my $fg (@fg)
    {
        $p{ $fg->repeat_id() } =
            { map { $_->name() => $params->{ $_->html_name() } } $fg->fields() };
    }

    return %p;
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
