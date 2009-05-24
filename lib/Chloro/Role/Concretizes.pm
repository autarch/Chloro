package Chloro::Role::Concretizes;

use strict;
use warnings;

use Class::MOP;
use MooseX::Role::Parameterized;
use MooseX::Types::Moose qw( HashRef Str );

requires 'as_concrete';

parameter name_map =>
    ( isa     => HashRef[Str],
      default => sub { {} },
    );

my $_get_concrete = sub
{
    my $meta = shift;
    my $name = $meta->name();

    $name =~ s/Abstract/Concrete/;

    return ( $name, Class::MOP::class_of($name) );
};

role
{
    my $p     = shift;
    my %extra = @_;

    my $metaclass = $extra{consumer};

    my ( $concrete_name, $concrete_meta ) = $_get_concrete->($metaclass);

    my $name_map = $p->name_map();

    my %predicates;
    my @copyable;
    for my $attr ( $metaclass->get_all_attributes() )
    {
        $predicates{ $attr->name() } = $attr->predicate()
            if $attr->has_predicate();

        next if exists $name_map->{ $attr->name() };
        next if ! defined $attr->init_arg();
        next if ! $concrete_meta->find_attribute_by_name( $attr->name() );

        $name_map->{ $attr->name() } = $attr->name();
    }

    method _concrete_clone => sub
    {
        my $self = shift;

        my %args;

        for my $source_attr ( keys %{ $name_map } )
        {
            my $pred = $predicates{$source_attr};
            next if $pred && ! $self->$pred();

            $args{ $name_map->{$source_attr} } = $self->$source_attr();
        }

        return $concrete_name->new( %args, @_ );
    };
};

no MooseX::Role::Parameterized;

1;
