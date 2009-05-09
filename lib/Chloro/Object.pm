package Chloro::Object;

use strict;
use warnings;

use Chloro::Types qw( :all );
use MooseX::Types::Moose qw( HashRef );

use Moose;

has 'params' =>
    ( is      => 'ro',
      isa     => HashRef,
      default => sub { {} },
    );

has 'form' =>
    ( is       => 'ro',
      isa      => 'Chloro::Form',
      default  => sub { $_[0]->meta()->form()->clone() },
      init_arg => undef,
    );

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

no Moose;

__PACKAGE__->meta()->make_immutable();

1;
