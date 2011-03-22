use strict;
use warnings;

use Test::More 0.88;

use lib 't/lib';

use Chloro::Test::Login;
use Chloro::Types qw( Bool Str );
use List::MoreUtils qw( all );

my $form = Chloro::Test::Login->new();

{
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

{
    my $set = $form->process(
        params => {
            username => 'foo',
            password => 'bar',
            remember => undef,
        }
    );

    ok(
        $set->is_valid(),
        'the returned result set says the form values are valid'
    );

    ok(
        ( all { $_->is_valid() } $set->_result_values() ),
        'all individual results are marked as valid'
    );

    is_deeply(
        { $set->results_hash() },
        {
            username => 'foo',
            password => 'bar',
        },
        'results_hash returns expected values'
    );
}

{
    my $set = $form->process(
        params => {
            username => 'foo',
            password => 'bar',
            remember => 1,
        }
    );

    is_deeply(
        { $set->results_hash() },
        {
            username => 'foo',
            password => 'bar',
            remember => 1,
        },
        'results_hash returns expected values (remember == 1)'
    );
}

{
    my $set = $form->process(
        params => {
            username => 'foo',
        }
    );

    ok(
        !$set->is_valid(),
        'result set is not valid when password is not provided'
    );

    my $pw_result = $set->result_for('password');

    ok(
       !$pw_result->is_valid(),
        'result for password is not valid'
    );

    is_deeply(
        [
            map { ref $_->error(), $_->error()->message() }
                $pw_result->errors()
        ],
        [
            'Chloro::ErrorMessage::Missing', 'The password field is required.'
        ],
        'errors for password result'
    );
}

{
    my $set = $form->process(
        params => {
            username => 'foo',
            password => undef,
        }
    );

    my $pw_result = $set->result_for('password');

    ok(
       !$pw_result->is_valid(),
        'result for password is not valid (password is undef)'
    );

    is_deeply(
        [
            map { ref $_->error(), $_->error()->message() }
                $pw_result->errors()
        ],
        [
            'Chloro::ErrorMessage::Missing', 'The password field is required.'
        ],
        'errors for password result'
    );
}

{
    my $set = $form->process(
        params => {
            username => 'foo',
            password => q{},
        }
    );

    my $pw_result = $set->result_for('password');

    ok(
       !$pw_result->is_valid(),
        'result for password is not valid (password is empty string)'
    );

    is_deeply(
        [
            map { ref $_->error(), $_->error()->message() }
                $pw_result->errors()
        ],
        [
            'Chloro::ErrorMessage::Missing', 'The password field is required.'
        ],
        'errors for password result'
    );
}

{
    my $set = $form->process(
        params => {
            username => 'foo',
            password => [],
        }
    );

    my $pw_result = $set->result_for('password');

    ok(
       !$pw_result->is_valid(),
        'result for password is not valid (password is an array ref)'
    );

    is_deeply(
        [
            map { ref $_->error(), $_->error()->message() }
                $pw_result->errors(),
        ],
        [
            'Chloro::ErrorMessage::Invalid',
            'The password field did not contain a valid value.'
        ],
        'errors for password result'
    );
}

done_testing();
