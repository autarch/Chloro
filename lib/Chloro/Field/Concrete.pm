package Chloro::Field::Concrete;

use strict;
use warnings;

use Chloro::Types qw( NonEmptyStr );
use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

extends 'Chloro::Field';

has html_name =>
    ( is       => 'ro',
      isa      => NonEmptyStr,
      lazy     => 1,
      builder  => '_build_html_name',
      init_arg => undef,
    );

has '+group' => ( isa => 'Chloro::FieldGroup::Concrete' );

has '+_form' => ( isa => 'Chloro::Form::Concrete' );

sub _build_html_name
{
    my $self = shift;

    my $group = $self->group()
        or die 'Cannot generate an html name for a field that does not belong to a group.';

    my $form = $self->_form()
        or die 'Cannot generate an html name for a field that is not part of a form.';

    return $self->name() if $group->is_implicit();

    return join q{.}, $group->name(), $self->name();
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
