package Chloro::Error::Field;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Field;
use Chloro::Types qw( NonEmptyStr );

with 'Chloro::Role::Error';

has field => (
    is       => 'ro',
    isa      => 'Chloro::Field',
    required => 1,
);

has message => (
    is       => 'ro',
    isa      => 'Chloro::ErrorMessage',
    required => 1,
);

__PACKAGE__->meta()->make_immutable();

1;

# ABSTRACT: An error associated with a specific field

__END__

=head1 SYNOPSIS

    my $errors = $resultset->result_for('field')->errors();

    for my $message ( @{$errors} ) {
        print $message->field()->name();
        print ': ';
        print $message->error()->message();
    }

=head1 DESCRIPTION

This class represents an error associated with a field.

=head1 METHODS

This class has the following methods:

=head2 $error->field()

Returns the L<Chloro::Field> object associated with this error.

=head2 $error->message()

Returns a L<Chloro::ErrorMessage> object.

=head1 ROLES

This object does the L<Chloro::Role::Error> role.

=cut
