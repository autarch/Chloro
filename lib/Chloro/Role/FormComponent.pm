package Chloro::Role::FormComponent;

use Moose::Role;

use namespace::autoclean;

use Chloro::Types qw( NonEmptyStr );

has name => (
    is       => 'ro',
    isa      => NonEmptyStr,
    required => 1,
);

has human_name => (
    is      => 'ro',
    isa     => NonEmptyStr,
    lazy    => 1,
    builder => '_build_human_name',
);

sub _build_human_name {
    my $self = shift;

    my $name = $self->name();

    $name =~ s/_/ /g;

    return $name;
}

1;

# ABSTRACT: A role for named things which are part of a form (fields and groups)

__END__

=head1 DESCRIPTION

This role defines two attributes which are shared between fields and groups,
C<name> and C<human_name>.

=cut

