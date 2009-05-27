use strict;
use warnings;

use Test::Exception;
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

    ::login_form_tests(__PACKAGE__);
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

{
    package Test::Form::User;

    use Chloro;

    fieldset 'Basic Info';
    field 'first_name' => ( required => 1 );
    field 'last_name' => ( required => 1 );
    field 'occupation';

    fieldset 'Websites';
    group 'website';
    field 'label';
    field 'uri'   => ( required => 1 );
}

{
    my $form = Test::Form::User->new( params  => {},
                                      repeats => { website => [ 1, 2, 'new1' ] },
                                    );

    ok( ! $form->is_valid(), 'form is not valid with no parameters' );

    my @e = $form->errors();
    is( scalar @e, 2, '2 errors' );

    is_deeply( [ map { { field   => $_->field()->html_name(),
                         message => $_->message() } }
                 sort { $a->field()->name() cmp $b->field()->name() }
                 @e ],
               [ { field   => 'first_name',
                   message => 'first_name is a required field.',
                 },
                 { field   => 'last_name',
                   message => 'last_name is a required field.',
                 }
               ],
               'got the expected errors' );
}

{
    my $form = Test::Form::User->new( params  => { first_name => 'Joe',
                                                   last_name  => 'Schmoe',
                                                 },
                                      repeats => { website => [ 1, 2, 'new1' ] },
                                    );

    ok( $form->is_valid(), 'form is valid' );

    my %fsp = $form->params_for_fieldset('Basic Info');
    is_deeply( \%fsp,
               { first_name => 'Joe',
                 last_name  => 'Schmoe',
                 occupation => undef,
               },
               'params_for_fieldset returns expected value' );

    throws_ok( sub { $form->params_for_fieldset('Websites') },
               qr/\QCannot call params_for_fieldset on a fieldset (Websites) with named groups/,
               'cannot call params_for_fieldset on a set with named groups' );

    my %fgp = $form->params_for_group('website');
    is_deeply( \%fgp,
               { 1    => { label => undef, uri => undef },
                 2    => { label => undef, uri => undef },
                 new1 => { label => undef, uri => undef },
               },
               'params_for_group returns expected value' );
}

{
    my $form = Test::Form::User->new( params  => { first_name        => 'Joe',
                                                   last_name         => 'Schmoe',
                                                   'website.1.label' => 'Blog',
                                                 },
                                      repeats => { website => [ 1, 2, 'new1' ] },
                                    );

    ok( ! $form->is_valid(), 'form is valid' );

    my @e = $form->errors();
    is_deeply( [ map { { field   => $_->field()->html_name(),
                         message => $_->message() } }
                 sort { $a->field()->name() cmp $b->field()->name() }
                 @e ],
               [ { field   => 'website.1.uri',
                       message => 'uri is a required field.',
                 },
               ],
               'got the expected error (cannot have a website label without a uri' );
}



{
    my $form =
        Test::Form::User->new
                ( params  => { first_name           => 'Joe',
                               last_name            => 'Schmoe',
                               'website.1.label'    => 'Blog',
                               'website.1.uri'      => 'http://www.example.com/1',
                               'website.2.uri'      => 'http://www.example.com/2',
                               'website.new1.label' => 'Crog',
                               'website.new1.uri'   => 'http://www.example.com/new',
                             },
                  repeats => { website => [ 1, 2, 'new1' ] },
                );

    my %fgp = $form->params_for_group('website');
    is_deeply( \%fgp,
               { 1    => { label => 'Blog', uri => 'http://www.example.com/1' },
                 2    => { label => undef,  uri => 'http://www.example.com/2' },
                 new1 => { label => 'Crog', uri => 'http://www.example.com/new' },
               },
               'params_for_group returns expected value' );
}
