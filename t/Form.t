use strict;
use warnings;

use Test::Exception;
use Test::More 'no_plan';

use Chloro::FieldSet;
use Chloro::Form;


{
    my $form = Chloro::Form->new();

    my $fs = $form->current_fieldset();
    isa_ok( $fs, 'Chloro::FieldSet',
            'current_fieldset' );
    ok( $fs->is_implicit(),
        'calling current_fieldset makes an implicit fieldset if needed' );

    throws_ok( sub { $form->add_fieldset( Chloro::FieldSet->new( name => 'foo' ) ) },
               qr/\QCannot add a fieldset (foo) to a form with an implicit fieldset/,
               'cannot add a fieldset to a form with an implicit fieldset' );
}

{
    my $form = Chloro::Form->new();

    $form->add_fieldset( Chloro::FieldSet->new( name => 'foo' ) );
    my $fs = $form->current_fieldset();
    isa_ok( $fs, 'Chloro::FieldSet',
            'current_fieldset' );
    is( $fs->name(), 'foo',
        'current_fieldset returns a non-implicit set if we have one' );

    $form->add_fieldset( Chloro::FieldSet->new( name => 'bar' ) );
    is( $form->current_fieldset()->name(), 'bar',
        'current_fieldset returns most recently added set' );
}

{
    my $form1 = Chloro::Form->new();
    $form1->add_fieldset( Chloro::FieldSet->new( name => 'foo' ) );

    my $form2 = Chloro::Form->new();
    $form1->add_fieldset( Chloro::FieldSet->new( name => 'bar' ) );

    $form1->include_form($form2);

    my @fs = $form1->fieldsets();
    is( scalar @fs , 2,
        'form1 has two fieldsets after including form2' );
    is_deeply( [ map { $_->name() } @fs ],
               [ 'foo', 'bar' ],
               'the two sets are foo and bar' );
}

{
    my $form1 = Chloro::Form->new();
    my $foo_fs = Chloro::FieldSet->new( name => 'foo' );

    $form1->add_fieldset($foo_fs);

    throws_ok( sub { $form1->add_fieldset($foo_fs) },
               qr/\QCannot add a fieldset (foo) to this form because it already has a fieldset of the same name./,
               'cannot add two fieldsets with the same name' );
}
