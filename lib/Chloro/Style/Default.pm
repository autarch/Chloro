package Chloro::Style::Default;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw( Str );

with 'Chloro::Role::Style';

sub missing_field_error
{
    my $self  = shift;
    my $field = shift;

    return $field->name() . ' is a required field.';
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
