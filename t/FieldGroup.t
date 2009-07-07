use strict;
use warnings;

use Test::Exception;
use Test::More 'no_plan';

use Chloro::Field::Abstract;
use Chloro::FieldGroup::Abstract;


{
    my $fg = Chloro::FieldGroup::Abstract->new( name => 'X' );

    $fg->add_field( Chloro::Field::Abstract->new( name => 'foo' ) );

    throws_ok( sub { $fg->add_field( Chloro::Field::Abstract->new( name => 'foo' ) ) },
               qr/\QCannot add a Chloro::Field::Abstract (foo) because we already have a Chloro::Field::Abstract of the same name/,
               'cannot add two fields with the same name' );
}
