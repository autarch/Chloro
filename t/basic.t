use strict;
use warnings;

use Test::More 0.88;

use lib 't/lib';

use Chloro::Test::Login;
use Chloro::Types qw( Bool Str );

{
    my $form = Chloro::Test::Login->new();

    my %fields = map {
        $_->name() => {
            type     => $_->type(),
            required => $_->is_required(),
            secure   => $_->is_secure(),
            }
    } $form->fields();

    is_deeply(
        \%fields, {
            username => {
                type     => Str,
                required => 1,
                secure   => 0,
            },
            password => {
                type     => Str,
                required => 1,
                secure   => 1,
            },
            remember => {
                type     => Bool,
                required => 0,
                secure   => 0,
            },
        },
        'field metadata'
    );
}

done_testing();
