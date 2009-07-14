use strict;
use warnings;

use Test::More 'no_plan';

{
    package Simple;

    use Chloro;

    field 'foo';
    field 'bar';
}

{
    ok( Simple->isa('Chloro::Object'),
        'Simple subclasses Chloro::Object after use Chloro' );

    isa_ok( Simple->meta()->form(), 'Chloro::Form',
            'Simple->meta()->form' );

    my $simple = Simple->new( action => '/' );
    isa_ok( $simple, 'Chloro::Object',
            'Simple object' );

    isa_ok( $simple->form(), 'Chloro::Form',
            '$simple->form' );

    my @fs = $simple->form()->fieldsets();
    is( scalar @fs, 1, 'form has one fieldset' );
    ok( $fs[0]->is_implicit(), 'fieldset is implicit' );

    my @g = $fs[0]->groups();
    is( scalar @g, 1, 'form has one group' );
    ok( $g[0]->is_implicit(), 'group is implicit' );

    my @f = $g[0]->fields();
    is( scalar @f, 2, 'group has two fields' );
    is( $f[0]->name(), 'foo', 'first field is foo' );
    is( $f[1]->name(), 'bar', 'second field is bar' );
}
