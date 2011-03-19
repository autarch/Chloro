package Chloro;

use strict;
use warnings;

use Chloro::Field;
use Chloro::Role::Form;
use Chloro::Trait::Class;
use Moose::Exporter;
use Moose::Util::MetaRole;

Moose::Exporter->setup_import_methods(
    with_meta => ['field'],
);

sub init_meta {
    shift;
    my %p = @_;

    Moose->init_meta(%p);

    Moose::Util::MetaRole::apply_metaroles(
        for             => $p{for_class},
        class_metaroles => { class => ['Chloro::Trait::Class'] },
    );

    Moose::Util::MetaRole::apply_base_class_roles(
        for   => $p{for_class},
        roles => ['Chloro::Role::Form'],
    );

    return;
}

sub field {
    my $meta = shift;

    my $field = Chloro::Field->new(
        name => shift,
        @_,
    );

    $meta->add_field($field);

    return;
}

1;
