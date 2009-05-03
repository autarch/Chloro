package Chloro::Object;

use strict;
use warnings;

use Moose;

extends 'Moose::Object';


sub BUILDARGS
{
    my $class = shift;

    my $params = $class->SUPER::BUILDARGS(@_);

    $class->_delete_empty_fields($params)
        if $class->meta()->ignore_empty_fields();

    return $params;
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

no Moose;

__PACKAGE__->meta()->make_immutable( inline_constructor => 0 );

1;
