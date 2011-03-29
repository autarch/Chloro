package Chloro::Field;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Types qw( Bool CodeRef Str Value );

with 'Chloro::Role::FormComponent';

has type => (
    is       => 'ro',
    isa      => 'Moose::Meta::TypeConstraint',
    required => 1,
    init_arg => 'isa',
);

has default => (
    is        => 'ro',
    isa       => Value | CodeRef,
    predicate => 'has_default',
);

has is_required => (
    is       => 'ro',
    isa      => Bool,
    init_arg => 'required',
    default  => 0,
);

has is_secure => (
    is       => 'ro',
    isa      => Bool,
    init_arg => 'secure',
    default  => 0,
);

my $_default_extractor = sub {
    my $self   = shift;
    my $key    = shift;
    my $params = shift;
    my $form   = shift;

    return $params->{$key};
};

has extractor => (
    is      => 'ro',
    isa     => CodeRef,
    default => sub {$_default_extractor},
);

my $_default_validator = sub {
    my $self   = shift;
    my $value  = shift;
    my $params = shift;
    my $form   = shift;

    return $self->type()->validate($value);
};

has validator => (
    is      => 'ro',
    isa     => CodeRef,
    default => sub {$_default_validator},
);

# This exists mostly to make testing easier
sub dump {
    my $self = shift;

    return (
        type     => $self->type(),
        required => $self->is_required(),
        secure   => $self->is_secure(),
        ( $self->has_default() ? ( default => $self->default() ) : () ),
    );
}

sub generate_default {
    my $self   = shift;
    my $params = shift;
    my $prefix = shift;

    my $default = $self->default();

    return ref $default
        ? $self->$default( $params, $prefix )
        : $default;
}

sub value_is_valid {
    my $self   = shift;

    return $self->validator()->( $self, @_ );
}

__PACKAGE__->meta()->make_immutable();

1;
