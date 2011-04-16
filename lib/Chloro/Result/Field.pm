package Chloro::Result::Field;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Types qw( ArrayRef Item );

with 'Chloro::Role::Result';

has _errors => (
    traits   => ['Array'],
    isa      => ArrayRef ['Chloro::Error::Field'],
    init_arg => 'errors',
    required => 1,
    handles  => {
        errors   => 'elements',
        is_valid => 'is_empty',
    },
);

has field => (
    is       => 'ro',
    isa      => 'Chloro::Field',
    required => 1,
);

has value => (
    is        => 'ro',
    isa       => Item,
    predicate => 'has_value',
);

sub key_value_pairs {
    my $self = shift;

    return unless $self->has_value();

    return ( $self->field->name() => $self->value() );
}

__PACKAGE__->meta()->make_immutable();

1;

# ABSTRACT: A result for a single field

__END__

=head1 SYNOPSIS

    my $result = $resultset->result_for('field');

    print $result->field()->name() . ' = ' . $result->value();

=head1 DESCRIPTION

This class represents the result for a single field after processing
user-submitted data.

=head1 METHODS

This class has the following methods:

=head2 Chloro::Result::Field->new()

The constructor accepts the following arguments:

=over 4

=item * errors

An array reference of L<Chloro::Error::Field> objects. This is required, but
can be an empty reference.

=item * field

The L<Chloro::Field> object for this result.

=item * value

The value for the result. This can be any data type.

=back

=head2 $result->errors()

Returns a list of L<Chloro::Error::Field> objects for this result.

=head2 $result->is_valid()

Returns true if there are no errors associated with this result.

=head2 $result->field()

Returns the L<Chloro::Field> object for this result.

=head2 $result->value()

Returns the value for this field. This can be any data type, undef,
non-reference, reference, object, etc.

=head2 $result->key_value_pairs()

Returns the result as a key/value pair, where the key is the field name. This
is plural so that this class and the L<Chloro::Result::Group> class can share
an API.

=head1 ROLES

This class does the L<Chloro::Role::Result> role.

=cut
