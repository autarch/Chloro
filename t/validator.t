use strict;
use warnings;

use Test::More 0.88;

use lib 't/lib';

use Chloro::Test::Validator;
use Chloro::Types qw( Bool Str );
use List::MoreUtils qw( all );

my $form = Chloro::Test::Validator->new();

{
    my $set = $form->process(
        params => {
            min => 1,
            max => 10,
        }
    );

    is_deeply(
        { $set->results_hash() },
        {
            min => 1,
            max => 10,
        },
        'validation for max value passed'
    );
}

{
    my $set = $form->process(
        params => {
            min => 12,
            max => 10,
        }
    );

    my %errors = $set->field_errors();

    is(
        scalar keys %errors, 1,
        'one field has an error'
    );

    ok( $errors{max}, 'error is for max field' );

    is(
        scalar @{ $errors{max} },
        1,
        'max field has one error associated with it'
    );

    is_deeply(
        [
            ref $errors{max}->[0]->error(),
            $errors{max}->[0]->error()->message(),
        ],
        [
            'Chloro::ErrorMessage::Invalid',
            'The max value must be greater than the min value.'
        ],
        'got expected error type and message'
    );
}

done_testing();
