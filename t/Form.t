use strict;
use warnings;

use Test::Exception;
use Test::More 'no_plan';

use Chloro::FieldGroup::Abstract;
use Chloro::FieldSet::Abstract;
use Chloro::Form::Abstract;


{
    my $form = Chloro::Form::Abstract->new();

    my $fs = $form->current_fieldset();
    isa_ok( $fs, 'Chloro::FieldSet',
            'current_fieldset' );
    ok( $fs->is_implicit(),
        'calling current_fieldset makes an implicit fieldset if needed' );

    throws_ok( sub { $form->add_fieldset( Chloro::FieldSet::Abstract->new( name => 'foo' ) ) },
               qr/\QCannot add a fieldset (foo) to a form with an implicit fieldset/,
               'cannot add a fieldset to a form with an implicit fieldset' );
}

{
    my $form = Chloro::Form::Abstract->new();

    $form->add_fieldset( Chloro::FieldSet::Abstract->new( name => 'foo' ) );
    my $fs = $form->current_fieldset();
    isa_ok( $fs, 'Chloro::FieldSet',
            'current_fieldset' );
    is( $fs->name(), 'foo',
        'current_fieldset returns a non-implicit set if we have one' );

    $form->add_fieldset( Chloro::FieldSet::Abstract->new( name => 'bar' ) );
    is( $form->current_fieldset()->name(), 'bar',
        'current_fieldset returns most recently added set' );
}

{
    my $form1 = Chloro::Form::Abstract->new();
    $form1->add_fieldset( Chloro::FieldSet::Abstract->new( name => 'foo' ) );

    my $form2 = Chloro::Form::Abstract->new();
    $form1->add_fieldset( Chloro::FieldSet::Abstract->new( name => 'bar' ) );

    $form1->include_form($form2);

    my @fs = $form1->fieldsets();
    is( scalar @fs , 2,
        'form1 has two fieldsets after including form2' );
    is_deeply( [ map { $_->name() } @fs ],
               [ 'foo', 'bar' ],
               'the two sets are foo and bar' );
}

{
    my $form1 = Chloro::Form::Abstract->new();
    my $foo_fs1 = Chloro::FieldSet::Abstract->new( name => 'foo' );
    my $foo_fs2 = Chloro::FieldSet::Abstract->new( name => 'foo' );

    $form1->add_fieldset($foo_fs1);

    throws_ok( sub { $form1->add_fieldset($foo_fs2) },
               qr/\QCannot add a Chloro::FieldSet::Abstract (foo) because we already have a Chloro::FieldSet::Abstract of the same name./,
               'cannot add two fieldsets with the same name' );
}

{
    my $form = Chloro::Form::Abstract->new();

    $form->add_field( Chloro::Field->new( name => 'foo' ) );
    $form->add_field( Chloro::Field->new( name => 'bar' ) );

    my @fields = $form->fields();
    is( scalar @fields, 2, 'can get fields directly from simple form' );
}


{
    my $form = Chloro::Form::Abstract->new();

    $form->add_fieldset( Chloro::FieldSet::Abstract->new( name => 'foo' ) );

    throws_ok( sub { $form->fields() },
               qr/\QCannot call fields() on a form with named fieldsets/,
               'cannot call fields on a form with a named fieldset' );
}

{
    my $form = Chloro::Form::Abstract->new();

    throws_ok( sub { $form->add_group( Chloro::FieldGroup::Abstract->new( name => 'foo' ) ) },
               qr/\QCannot add a named group to an implicit fieldset/,
               'cannot add a named group to an implicit fieldset' );
}

{
    my $form = Chloro::Form::Abstract->new();

    $form->add_fieldset( Chloro::FieldSet::Abstract->new( name => 'Foo' ) );
    $form->add_group( Chloro::FieldGroup::Abstract->new( name => 'x' ) );
    $form->add_group( Chloro::FieldGroup::Abstract->new( name => 'y' ) );
    $form->add_group( Chloro::FieldGroup::Abstract->new( name => 'z' ) );

    my $fs = Chloro::FieldSet::Abstract->new( name => 'Bar' );
    $fs->add_group( Chloro::FieldGroup::Abstract->new( name => 'a' ) );
    $fs->add_group( Chloro::FieldGroup::Abstract->new( name => 'x' ) );

    throws_ok( sub { $form->add_fieldset($fs) },
               qr/\QThis form already has a group named x/,
               'cannot have two groups with the same name in a form' );
}

{
    my $form = Chloro::Form::Abstract->new();

    $form->add_fieldset( Chloro::FieldSet::Abstract->new( name => 'Foo' ) );
    $form->add_group( Chloro::FieldGroup::Abstract->new( name => 'x' ) );

    $form->add_fieldset( Chloro::FieldSet::Abstract->new( name => 'Bar' ) );
    throws_ok( sub { $form->add_group( Chloro::FieldGroup::Abstract->new( name => 'x' ) ) },
               qr/\QThis form already has a group named x/,
               'cannot have two groups with the same name in a form' );
}
