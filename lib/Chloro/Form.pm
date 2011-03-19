package Chloro::Form;

use Moose;
use MooseX::StrictConstructor;

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

__PACKAGE__->meta()->make_immutable();

1;
