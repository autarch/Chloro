package Chloro::Role::HasCollection;

use strict;
use warnings;

use Chloro::Types qw( :all );
use Chloro::UniqueNamedObjectArray;
use MooseX::Role::Parameterized;
use MooseX::Types::Moose qw( Str );
use Tie::IxHash;

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
    my $last_object = '_last_' . $thing;

    has $collection =>
        ( is      => 'ro',
          isa     => 'Chloro::UniqueNamedObjectArray',
          default => sub { Chloro::UniqueNamedObjectArray->new() },
          handles => { $plural         => 'objects',
                       $add            => 'add_object',
                       $get            => 'get_object',
                       'has_' . $thing => 'has_object',
                       $has_any        => 'has_objects',
                       $last_object    => 'last_object',
                     },
        );

    before $add => sub
    {
        my $self      = shift;
        my $new_thing = shift;

        if ( $self->$has_any() && $self->$current()->is_implicit() )
        {
            die "Cannot add a $thing (" . $new_thing->name() . ")"
                . " to a $container with an implicit $thing.\n"
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

        return $self->$last_object();
    };
};

no MooseX::Role::Parameterized;

1;
