use strict;
use warnings;

use Test::Exception;
use Test::More 'no_plan';

use Chloro::FieldGroup;
use Chloro::FieldSet;


{
    my $fs = Chloro::FieldSet->new( name => 'X' );

    my $fg = $fs->current_group();
    isa_ok( $fg, 'Chloro::FieldGroup',
            'current_group' );
    ok( $fg->is_implicit(),
        'calling current_group makes an implicit group if needed' );

    throws_ok( sub { $fs->add_group( Chloro::FieldGroup->new( name => 'foo' ) ) },
               qr/\QCannot add a group (foo) to a fieldset with an implicit group/,
               'cannot add a group to a fieldset with an implicit group' );
}

{
    my $fs = Chloro::FieldSet->new( name => 'X' );

    $fs->add_group( Chloro::FieldGroup->new( name => 'foo' ) );
    my $fg = $fs->current_group();
    isa_ok( $fg, 'Chloro::FieldGroup',
            'current_group' );
    is( $fg->name(), 'foo',
        'current_group returns a non-implicit set if we have one' );

    $fs->add_group( Chloro::FieldGroup->new( name => 'bar' ) );
    is( $fs->current_group()->name(), 'bar',
        'current_group returns most recently added set' );
}

{
    my $fs1 = Chloro::FieldSet->new( name => 'X' );
    my $foo_fg = Chloro::FieldGroup->new( name => 'foo' );

    $fs1->add_group($foo_fg);

    throws_ok( sub { $fs1->add_group($foo_fg) },
               qr/\QCannot add a Chloro::FieldGroup (foo) because we already have a Chloro::FieldGroup of the same name./,
               'cannot add two groups with the same name' );
}
