package Chloro::Role::ResultSet;

use Moose::Role;

use namespace::autoclean;

use Chloro::Types qw( HashRef Result );

has _results => (
    traits   => ['Hash'],
    isa      => HashRef [Result],
    init_arg => 'results',
    required => 1,
    handles  => {
        results        => 'elements',
        result_for     => 'get',
        _result_values => 'values',
    },
);

1;

# ABSTRACT: An interface-only for resultset classes

__END__

=head1 DESCRIPTION

This role defines an interface for all resultsets, and is shared by the
L<Chloro::ResultSet> and L<Chloro::Result::Group> classes.

=cut
