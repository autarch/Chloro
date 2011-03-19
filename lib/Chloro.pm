package Chloro;

use strict;
use warnings;

use Chloro::Field;
use Chloro::Form;
use Chloro::Trait::Class;

Moose::Exporter->setup_import_methods(
    with_meta => ['field'],
);

sub init_meta {
    shift;
    my %p = @_;

    Moose->init_meta(
        %p,
        base_class => 'Chloro::Form',
    );

    Moose::Util::MetaRole::apply_metaroles(
        for             => $p{for_class},
        class_metaroles => { class => ['Chloro::Trait::Class'] },
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
