package Chloro::Role::HasCollection;

use strict;
use warnings;

use MooseX::Role::Parameterized;
use Chloro::Types;

param 'container' =>
    ( isa      => Str,
      required => 1,
    );

param 'thing' =>
    ( isa      => Str,
      required => 1,
    );

param 'class' =>
    ( isa      => ClassDoesImplicit,
      required => 1,
    );

role
{
    my $p = shift;

    my $conatiner = $p->container();
    my $thing     = $p->thing();
    my $plural    = $thing . 's';

    my $collection = q{_} . $plural;
    my $add        = 'add_' . $thing;
    my $has_any    = '_has_' . $plural;
    my $current    = 'current_' . $thing;

    has $collection =>
        ( is      => 'ro',
          isa     => 'Tie::IxHash',
          default => sub { Tie::IxHash->new() },
          handles => { $add     => 'Push',
                       'get_' . $thing => 'FETCH',
                       'has_' . $thing => 'EXISTS',
                       $has_any => 'Length',
                     },
        );

    before $add => sub
    {
        my $self      = shift;
        my $new_thing = shift;

        if ( $self->$has_any() && $self->$current()->is_implicit() )
        {
            die "Cannot add a $thing (" . $new_thing->name() . ")"
                . " to a $container with an implicit thing.\n"
                . " Please declare all your $plural explicitly.\n";
        }
    };

    my $class = $p->class();

    method $current => sub
    {
        my $self = shift;

        unless ( $self->$has_any() )
        {
            my $implicit = $class->new( name        => '__IMPLICIT__',
                                        is_implicit => 1,
                                      );

            $self->$add($implicit);
        }

        return $self->$collection()->Values(-1);
    };
}

no Moose::Role;

1;
