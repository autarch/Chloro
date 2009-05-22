use strict;
use warnings;

use Test::Exception;
use Test::More 'no_plan';

use Chloro::FieldGroup::Abstract;
use Chloro::FieldSet::Abstract;
use Chloro::Form::Abstract;

{
    my $form = Chloro::Form::Abstract->new();

    $form->add_fieldset( Chloro::FieldSet::Abstract->new( name => 'Foo' ) );
    $form->add_group( Chloro::FieldGroup::Abstract->new( name => 'foo1' ) );
    $form->add_field( Chloro::Field::Abstract->new( name => 'a1' ) );
    $form->add_field( Chloro::Field::Abstract->new( name => 'a2' ) );
    $form->add_field( Chloro::Field::Abstract->new( name => 'a3' ) );

    $form->add_fieldset( Chloro::FieldSet::Abstract->new( name => 'Bar' ) );
    $form->add_field( Chloro::Field::Abstract->new( name => 'b1' ) );
    $form->add_field( Chloro::Field::Abstract->new( name => 'b2' ) );

    my $conc = $form->as_concrete( repeats => { foo1 => [ qw( X Y ) ] } );

    isa_ok( $conc, 'Chloro::Form::Concrete', 'as_concrete return value' );

    my @fs = $conc->fieldsets();
    is( scalar @fs, 2, 'concrete form has two fieldsets' );
    isa_ok( $fs[0], 'Chloro::FieldSet::Concrete', 'first fieldset' );
    isa_ok( $fs[1], 'Chloro::FieldSet::Concrete', 'second fieldset' );
    is_deeply( [ map { $_->name() } @fs ],
               [ 'Foo', 'Bar' ],
               'concrete fieldsets have the correct name' );

    my @foo_fg = $fs[0]->groups();
    is( scalar @foo_fg, 2, 'Foo fieldset has two groups' );
    is( $foo_fg[0]->name(), 'foo1.X', 'name includes both base name and repeat id' );
    is( $foo_fg[1]->name(), 'foo1.Y', 'name includes both base name and repeat id' );

    my @foo_fields0 = $foo_fg[0]->fields();
    is( scalar @foo_fields0, 3, 'first group in Foo has 3 fields' );
    is( $foo_fields0[0]->html_name(), 'foo1.X.a1',
        'html_name for field incporate group name, repeat id, and field name' );

    my @foo_fields1 = $foo_fg[1]->fields();
    is( scalar @foo_fields1, 3, 'second group in Foo has 3 fields' );
    is( $foo_fields1[0]->html_name(), 'foo1.Y.a1',
        'html_name for field incporate group name, repeat id, and field name' );

    my @bar_fg = $fs[1]->groups();
    is( scalar @bar_fg, 1, 'Bar fieldset has one group' );
    is( $bar_fg[0]->name(), '__IMPLICIT__', 'implicit group' );

    my @bar_fields = $bar_fg[0]->fields();
    is( scalar @bar_fields, 2, 'Bar fieldset has two fields' );
    is( $bar_fields[0]->html_name(), 'b1',
        'html_name for field in implicit group is just the field name' );
}
