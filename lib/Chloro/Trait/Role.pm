package Chloro::Trait::Role;

use Moose::Role;

use namespace::autoclean;

with 'Chloro::Role::Trait::HasFormComponents';

sub composition_class_roles {
    return 'Chloro::Trait::Role::Composite';
}

1;
