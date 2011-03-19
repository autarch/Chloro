package Chloro::Field;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Types qw( Bool CodeRef Str );

has name => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has type => (
    is       => 'ro',
    isa      => 'Moose::Meta::TypeConstraint',
    required => 1,
    init_arg => 'isa',
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
    my $params = shift;

    return $params->{ $self->name() };
};

has extractor => (
    is      => 'ro',
    isa     => CodeRef,
    default => sub {$_default_extractor},
);

my $_default_validator = sub {1};

has validator => (
    is      => 'ro',
    isa     => CodeRef,
    default => sub {$_default_validator},
);

__PACKAGE__->meta()->make_immutable();

1;
