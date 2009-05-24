use strict;
use warnings;

use Test::Exception;
use Test::More 'no_plan';

use Chloro::FieldGroup::Abstract;
use Chloro::FieldSet::Abstract;


{
    my $fs = Chloro::FieldSet::Abstract->new( name => 'X' );

    my $fg = $fs->current_group();
    isa_ok( $fg, 'Chloro::FieldGroup::Abstract',
            'current_group' );
    ok( $fg->is_implicit(),
        'calling current_group makes an implicit group if needed' );

    throws_ok( sub { $fs->add_group( Chloro::FieldGroup::Abstract->new( name => 'foo' ) ) },
               qr/\QCannot add a group (foo) to a fieldset with an implicit group/,
               'cannot add a group to a fieldset with an implicit group' );
}

{
    my $fs = Chloro::FieldSet::Abstract->new( name => 'X' );

    $fs->add_group( Chloro::FieldGroup::Abstract->new( name => 'foo' ) );
    my $fg = $fs->current_group();
    isa_ok( $fg, 'Chloro::FieldGroup::Abstract',
            'current_group' );
    is( $fg->name(), 'foo',
        'current_group returns a non-implicit set if we have one' );
    is( $fg->fieldset(), $fs,
        'adding a fieldset sets the parent' );

    $fs->add_group( Chloro::FieldGroup::Abstract->new( name => 'bar' ) );
    is( $fs->current_group()->name(), 'bar',
        'current_group returns most recently added set' );
}

{
    my $fs = Chloro::FieldSet::Abstract->new( name => 'X' );
    my $foo_fg1 = Chloro::FieldGroup::Abstract->new( name => 'foo' );
    my $foo_fg2 = Chloro::FieldGroup::Abstract->new( name => 'foo' );

    $fs->add_group($foo_fg1);

    throws_ok( sub { $fs->add_group($foo_fg2) },
               qr/\QCannot add a Chloro::FieldGroup::Abstract (foo) because we already have a Chloro::FieldGroup::Abstract of the same name./,
               'cannot add two groups with the same name' );
}

{
    my $fs = Chloro::FieldSet::Abstract->new( name => 'X' );
    my $foo_fg = Chloro::FieldGroup::Abstract->new( name => 'foo' );
    $foo_fg->set_fieldset($fs);

    throws_ok( sub { $fs->add_group($foo_fg) },
               qr/\QCannot add a group that already has a fieldset/,
               'cannot add a group that already is in a fieldset' );
}

{
    my $fs = Chloro::FieldSet::Abstract->new( name => 'X' );

    $fs->add_group( Chloro::FieldGroup::Abstract->new( name => 'foo' ) );

    throws_ok( sub { $fs->fields() },
               qr/\QCannot call fields() on a fieldset with named field groups/,
               'cannot call fields on a fieldset with a named group' );
}
