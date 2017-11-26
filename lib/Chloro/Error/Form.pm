package Chloro::Error::Form;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.07';

use Moose;
use MooseX::StrictConstructor;

use Chloro::Field;

with 'Chloro::Role::Error';

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

    for my $error ( $resultset->form_errors() ) {
        print $error->error()->message();
    }

=head1 DESCRIPTION

This class represents an error associated with the form as a whole, not a
specific field.

=head1 METHODS

This class has the following methods:

=head2 $error->message()

Returns a L<Chloro::ErrorMessage> object.

=head1 ROLES

This object does the L<Chloro::Role::Error> role.

=cut
