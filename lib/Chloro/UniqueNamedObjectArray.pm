package Chloro::UniqueNamedObjectArray;

use strict;
use warnings;

use Carp qw( confess );
use Chloro::Types qw( NamedObject );
use Moose;
use MooseX::Params::Validate qw( pos_validated_list );

has _objects =>
    ( is      => 'ro',
      isa     => 'Tie::IxHash',
      default => sub { Tie::IxHash->new() },
      handles => { objects     => 'Values',
                   _add_object => 'STORE',
                   get_object  => 'FETCH',
                   has_object  => 'EXISTS',
                   has_objects => 'Length',
                 },
    );

sub add_object
{
    my $self = shift;
    my ($object) = pos_validated_list( \@_, { isa => NamedObject } );

    if ( $self->has_object( $object->name() ) )
    {
        my $type = ref $object;
        confess "Cannot add a $type (" . $object->name() . ")"
                . " because we already have a $type"
                . " of the same name.\n";
    }

    $self->_add_object( $object->name() => $object );
}

sub last_object
{
    my $self = shift;

    return $self->_objects()->Values(-1);
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
