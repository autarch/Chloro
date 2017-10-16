package Chloro::Trait::Application;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.07';

use Moose::Role;

after apply_attributes => sub {
    shift->_apply_form_components(@_);
};

1;

# ABSTRACT: A trait that supports role application for roles with Chloro fields and groups

__END__

=pod

=head1 DESCRIPTION

This trait is used to allow the application of roles containing Chloro fields
and groups/

=head1 BUGS

See L<Chloro> for details.

=cut
