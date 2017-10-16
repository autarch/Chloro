package Chloro::Role::Result;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.07';

use Moose::Role;

requires 'key_value_pairs';

1;

# ABSTRACT: An interface-only role for results

__END__

=head1 DESCRIPTION

This role defines an interface for all result objects.

It requires one method, C<< $result->key_value_pairs() >>.

=cut
