package Chloro::Object;

use strict;
use warnings;

use Chloro::Error;
use Chloro::Style::Default;
use Chloro::Types qw( :all );
use Moose;
use MooseX::AttributeHelpers;
use MooseX::Types::Moose qw( Bool ArrayRef HashRef );
use MooseX::StrictConstructor;

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

    my $repeats = delete $p->{repeats};

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

    for my $fs ( $self->form()->fieldsets() )
    {
        for my $fg ( $fs->groups() )
        {
            for my $field ( $fg->fields() )
            {
                if ( $field->is_required() )
                {
                    my $name = $field->html_name();

                    if ( ! exists $params->{$name} )
                    {
                        push @errors,
                            Chloro::Error->new( field   => $field,
                                                message => $self->style()->missing_field_error($field),
                                              );

                        next;
                    }
                }
            }
        }
    }

    return \@errors;
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
