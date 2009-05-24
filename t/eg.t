use strict;
use warnings;

use Test::More 'no_plan';


{
    package Test::Form::Login;

    use Chloro;

    field 'username' => ( required => 1 );
    field 'password' => ( required => 1 );

    ::login_form_tests(__PACKAGE__);
}

{
    package Test::Form::LoginWithFS;

    use Chloro;

    fieldset 'Foo';
    field 'username' => ( required => 1 );
    field 'password' => ( required => 1 );

    ::login_form_tests(__PACKAGE__);
}

{
    package Test::Form::LoginWithFSAndFG;

    use Chloro;

    fieldset 'Foo';
    group 'bar' => ( can_repeat => 0 );
    field 'username' => ( required => 1 );
    field 'password' => ( required => 1 );

    ::login_form_tests( __PACKAGE__, 'bar.__IMPLICIT__.' );
}


sub login_form_tests
{
    my $class  = shift;
    my $prefix = shift || q{};

    {
        my $form = $class->new( params => {} );

        ok( ! $form->is_valid(),
            "form is not valid with empty parameters [$class]" );

        my @e = $form->errors();
        is( scalar @e, 2, '2 errors' );

        is_deeply( [ map { { field   => $_->field()->html_name(),
                             message => $_->message() } }
                     sort { $a->field()->name() cmp $b->field()->name() }
                     @e ],
                   [ { field   => $prefix . 'password',
                       message => 'password is a required field.',
                     },
                     { field   => $prefix . 'username',
                       message => 'username is a required field.',
                     }
                   ],
                   "got the expected errors [$class]" );
    }

    {
        my $form = $class->new( params => { $prefix . 'username' => 'foo' } );

        ok( ! $form->is_valid(),
            "form is not valid without a password [$class]" );

        my @e = $form->errors();
        is( scalar @e, 1, '1 error' );

        is_deeply( [ map { { field   => $_->field()->html_name(),
                             message => $_->message() } }
                     sort { $a->field()->name() cmp $b->field()->name() }
                     @e ],
                   [ { field   => $prefix . 'password',
                       message => 'password is a required field.',
                     }
                   ],
                   "got the expected error [$class]" );
    }

    {
        my $form =
            $class->new
                ( params =>
                  { $prefix . username => 'foo',
                    $prefix . password => 'bar',
                  }
                );

        ok( $form->is_valid(), 'form is valid' );

        my @e = $form->errors();
        is( scalar @e, 0, "0 errors [$class]" );
    }
}