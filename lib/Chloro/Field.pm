package Chloro::Field;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Types qw( Bool CodeRef NonEmptySimpleStr Str Value );
use Moose::Util::TypeConstraints;

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

has extractor => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    default => 'extract_field_value',
);

has validator => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    default => 'errors_for_field_value',
);

override BUILDARGS => sub {
    my $class = shift;

    my $p = super();

    $p->{isa}
        = Moose::Util::TypeConstraints::find_or_create_isa_type_constraint(
        $p->{isa} );

    return $p;
};

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

# The Storable hooks are needed because the Moose::Meta::TypeConstraint object
# contains a code reference, and Storable will just die if it tries to
# serialize it. So we save the type's _name_ and look that up when thawing.
#
# Unfortunately, this requires poking around in the object guts a little bit.
sub STORABLE_freeze {
    my $self = shift;

    my %copy = %{$self};

    my $type = delete $copy{type};

    return q{}, \%copy, \( $type->name() );
}

sub STORABLE_thaw {
    my $self = shift;
    shift;
    shift;
    my $obj  = shift;
    my $type = shift;

    %{$self} = %{$obj};

    $self->{type}
        = Moose::Util::TypeConstraints::find_or_create_type_constraint( ${$type} );

    return;
}

__PACKAGE__->meta()->make_immutable();

1;
