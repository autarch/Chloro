use strict;
use warnings;

use Test::More 'no_plan';


{
    package Test::Form::Login;

    use Chloro;

    field 'username' => ( required => 1 );
    field 'password' => ( required => 1 );
}

{
    my $form = Test::Form::Login->new( params => {} );

    ok( ! $form->is_valid(),
        'form is not valid with empty parameters' );

    my @e = $form->errors();
    is( scalar @e, 2, '2 errors' );

    is_deeply( [ map { { field   => $_->field()->name(),
                         message => $_->message() } }
                 sort { $a->field()->name() cmp $b->field()->name() }
                 @e ],
               [ { field   => 'password',
                   message => 'password is a required field.',
                 },
                 { field   => 'username',
                   message => 'username is a required field.',
                 }
               ],
               'got the expected errors' );
}

