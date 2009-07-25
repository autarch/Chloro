use strict;
use warnings;

use Test::Exception;
use Test::More tests => 2;

use Chloro::FieldType;
use Chloro::Types qw( PosInt );
use Moose::Util::TypeConstraints qw( find_type_constraint );
use Storable qw( nfreeze thaw );


for my $real_type ( find_type_constraint('Int'), PosInt )
{
    my $chloro_type = Chloro::FieldType->new( type => $real_type );
    my $thawed = thaw( nfreeze($chloro_type) );

    is( $chloro_type->type(), $thawed->type(),
        'underlying type is restored after Storable freeze/thaw' );
}
