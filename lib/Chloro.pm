package Chloro;

use strict;
use warnings;

use Chloro::Field;
use Chloro::Group;
use Chloro::Role::Form;
use Chloro::Trait::Class;
use Moose::Exporter;
use Moose::Util::MetaRole;
use Scalar::Util qw( blessed );

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

    # Called inside a call to group()
    if (wantarray) {
        return $field;
    }
    else {
        $meta->add_field($field);
    }

    return;
}

sub group {
    my $meta = shift;

    my @fields;
    push @fields, pop @_ while blessed $_[-1];

    my $group = Chloro::Group->new(
        name => shift,
        fields => \@fields,
        @_,
    );

    $meta->add_group($group);
}

1;
