package Chloro::Role::Form;

use Moose::Role;

use namespace::autoclean;

use Chloro::ResultSet;
use Chloro::Types qw( HashRef );
use MooseX::Params::Validate qw( validated_list );

sub fields {
    my $self = shift;

    return $self->meta()->fields();
}

sub process {
    my $self = shift;
    my ($params) = validated_list(
        \@_,
        params => { isa => HashRef },
    );

}

1;
