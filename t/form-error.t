use strict;
use warnings;

use Test::More 0.88;

use lib 't/lib';

use Chloro::Test::User;

my $form = Chloro::Test::User->new();

{
    my $result_set = $form->process(
        params => {
            username      => 'Foo',
            email_address => 'foo@example.com',
        }
    );

    ok(
        $result_set->is_valid(),
        'form is valid when no password fields are present'
    );
}

{
    my $result_set = $form->process(
        params => {
            username      => 'Foo',
            email_address => 'foo@example.com',
            password      => 'pw',
            password2     => 'pw',
        }
    );

    ok(
        $result_set->is_valid(),
        'form is valid when password fields match'
    );
}

{
    my $result_set = $form->process(
        params => {
            username      => 'Foo',
            email_address => 'foo@example.com',
            password      => 'pw',
        }
    );

    ok(
        !$result_set->is_valid(),
        'form is invalid when one password field is empty'
    );

    is_deeply(
        [
            map { [ $_->message()->category(), $_->message()->text() ] }
                $result_set->form_errors()
        ],
        [
            [
                'invalid',
                'The two password fields must match.'
            ]
        ],
        'got expected form errors'
    );
}

{
    my $result_set = $form->process(
        params => {
            username      => 'Foo',
            email_address => 'foo@example.com',
            password      => 'pw',
            password2     => 'bad',
        }
    );

    ok(
        !$result_set->is_valid(),
        'form is invalid when password fields do not match'
    );

    is_deeply(
        [
            map { [ $_->message()->category(), $_->message()->text() ] }
                $result_set->form_errors()
        ],
        [
            [
                'invalid',
                'The two password fields must match.'
            ]
        ],
        'got expected form errors'
    );
}

{
    my $result_set = $form->process(
        params => {
            username      => 'Special',
            email_address => 'foo@example.com',
            password      => 'pw',
            password2     => 'bad',
        }
    );

    ok(
        !$result_set->is_valid(),
        'form is invalid when password fields do not match'
    );

    is_deeply(
        [
            map { [ $_->message()->category(), $_->message()->text() ] }
                $result_set->form_errors()
        ],
        [
            [
                'invalid',
                'The two password fields must match.'
            ],
            [
                'missing',
                'Special is no good.'
            ]
        ],
        'got expected form errors'
    );
}

done_testing();
