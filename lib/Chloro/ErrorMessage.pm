package Chloro::ErrorMessage;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.08';

use Moose;
use MooseX::StrictConstructor;

use Chloro::Types qw( NonEmptyStr );

has category => (
    is       => 'ro',
    isa      => NonEmptyStr,
    required => 1,
);

has text => (
    is       => 'ro',
    isa      => NonEmptyStr,
    required => 1,
);

__PACKAGE__->meta()->make_immutable();

1;

# ABSTRACT: An error message

__END__

=head1 SYNOPSIS

    print $message->category . ': ' . $message->text();

=head1 DESCRIPTION

This class represents an error message. A message has a category and message
text.

=head1 METHODS

This class has the following methods:

=head2 $error->category()

This is a string that tells what kind of error message this is. By default,
Chloro only uses "invalid" and "missing", but there's nothing preventing you
from using other categories in your code.

=head2 $error->text()

The text of the error message.

=cut
