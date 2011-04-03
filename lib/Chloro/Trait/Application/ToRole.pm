package Chloro::Trait::Application::ToRole;

use Moose::Role;

use namespace::autoclean;

with 'Chloro::Trait::Application';

around apply => sub {
    my $orig  = shift;
    my $self  = shift;
    my $role1 = shift;
    my $role2 = shift;

    unless ( does_role( $role2, 'Chloro::Trait::Role' ) ) {
        $role2 = Moose::Util::MetaRole::apply_metaroles(
            for            => $role2,
            role_metaroles => {
                role => ['Chloro::Trait::Role'],
                application_to_class =>
                    ['Chloro::Trait::Application::ToClass'],
                application_to_role =>
                    ['Chloro::Trait::Application::ToRole'],
            },
        );
    }

    $self->$orig( $role1, $role2 );
};

sub _apply_form_components {
    my $self  = shift;
    my $role1 = shift;
    my $role2 = shift;

    foreach my $field ( $role1->fields() ) {
        if ( $role2->_has_field( $field->name() ) ) {

            require Moose;
            Moose->throw_error( "Role '"
                    . $role1->name()
                    . "' has encountered a field conflict "
                    . "during composition. This is fatal error and cannot be disambiguated."
            );
        }
        else {
            $role2->add_field($field);
        }
    }

    foreach my $group ( $role1->groups() ) {
        if ( $role2->_has_group( $group->name() ) ) {

            require Moose;
            Moose->throw_error( "Role '"
                    . $role1->name()
                    . "' has encountered a group conflict "
                    . "during composition. This is fatal error and cannot be disambiguated."
            );
        }
        else {
            $role2->add_group($group);
        }
    }
}

1;

# ABSTRACT: A trait that supports applying Chloro fields and groups to roles

__END__

=pod

=head1 DESCRIPTION

This trait is used to allow the application of roles containing Chloro fields
and groups.

=head1 BUGS

See L<Chloro> for details.

=cut
