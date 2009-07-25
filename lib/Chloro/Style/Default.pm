package Chloro::Style::Default;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw( Str );

with 'Chloro::Role::Style';

sub label_from_name
{
    my $self = shift;
    my $name = shift;

    ( my $label = $name ) =~ s/_/ /g;

    return ucfirst $label;
}

sub missing_field_error
{
    my $self  = shift;
    my $field = shift;

    return $field->label() . ' is a required field.';
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
