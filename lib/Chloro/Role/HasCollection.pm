package Chloro::Role::HasCollection;

use strict;
use warnings;

use Chloro::Types qw( :all );
use MooseX::Types::Moose qw( Str );
use Tie::IxHash;

use MooseX::Role::Parameterized;

parameter container =>
    ( isa      => Str,
      required => 1,
    );

parameter thing =>
    ( isa      => Str,
      required => 1,
    );

parameter class =>
    ( does     => ClassDoesImplicit,
      required => 1,
    );

role
{
    my $p = shift;

    my $container = $p->container();
    my $thing     = $p->thing();
    my $plural    = $thing . 's';

    my $collection  = q{_} . $plural;
    my $add         = 'add_' . $thing;
    my $private_add = q{_} . $add;
    my $get         = 'get_' . $thing;
    my $has_any     = '_has_' . $plural;
    my $current     = 'current_' . $thing;

    has $collection =>
        ( is      => 'ro',
          isa     => 'Tie::IxHash',
          default => sub { Tie::IxHash->new() },
          handles => { $plural         => 'Values',
                       $private_add    => 'STORE',
                       $get            => 'FETCH',
                       'has_' . $thing => 'EXISTS',
                       $has_any        => 'Length',
                     },
        );

    method $add => sub
    {
        my $self      = shift;
        my $new_thing = shift;

        if ( $self->$has_any() && $self->$current()->is_implicit() )
        {
            die "Cannot add a $thing (" . $new_thing->name() . ")"
                . " to a $container with an implicit $thing.\n"
                . " Please declare all your $plural explicitly.\n";
        }

        if ( $self->$get( $new_thing->name() ) )
        {
            die "Cannot add a $thing (" . $new_thing->name() . ")"
                . " to this $container because it already has a $thing"
                . " of the same name.\n";
        }


        $self->$private_add( $new_thing->name() => $new_thing );
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
};

no MooseX::Role::Parameterized;

1;
