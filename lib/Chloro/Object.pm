package Chloro::Object;

use strict;
use warnings;

use Chloro::Error;
use Chloro::Style::Default;
use Chloro::Types qw( :all );
use Moose;
use MooseX::AttributeHelpers;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw( Bool ArrayRef HashRef );

has 'params' =>
    ( is      => 'ro',
      isa     => HashRef,
      default => sub { {} },
    );

has 'form' =>
    ( is       => 'rw',
      writer   => '_set_form',
      isa      => 'Chloro::Form::Concrete',
      handles  => [ qw( style ) ],
      init_arg => undef,
    );

has validate_empty_fields =>
    ( is      => 'ro',
      isa     => Bool,
      default => 0,
    );

has _errors =>
    ( metaclass => 'Collection::Array',
      is        => 'ro',
      isa       => ArrayRef['Chloro::Error'],
      lazy      => 1,
      builder   => '_validate_form',
      init_arg  => undef,
      provides  => { elements => 'errors',
                     push     => 'add_error',
                     empty    => 'has_errors',
                   },
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

sub _validate_form
{
    my $self = shift;

    my @errors;

    my $params = $self->params();

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
                map { Chloro::Error->new( field   => $_,
                                          message => $self->style()->missing_field_error($_),
                                        ) }
                grep { $_->is_required() }
                    @empty;

            push @errors,
                map { Chloro::Error->new( field   => $_,
                                          message => $field->error_message($_),
                                        ) }
                grep { ! $_->value_is_valid( $self->params->{ $_->html_name() } ) }
                    @non_empty;

        }
    }

    return \@errors;
}

sub _field_is_empty
{
    my $self  = shift;
    my $field = shift;

    return 0 if $field->is_boolean();

    my $val = $self->params()->{ $field->html_name() };

    return ! ( defined $val && length $val );
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

    return map { $_ => $self->params()->{$_} } map { $_->html_name() } $fg[0]->fields();
}

sub params_for_group
{
    my $self = shift;
    my $name = shift;

    my @fg = grep { $_->base_name() eq $name } map { $_->groups() } $self->form()->fieldsets();
    return unless @fg;

    my $params = $self->params();

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
