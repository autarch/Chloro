package Chloro;

use strict;
use warnings;

use Chloro::Field;
use Chloro::Group;
use Chloro::Role::Form;
use Chloro::Trait::Class;
use Moose::Exporter;
use Moose::Util::MetaRole;
use Scalar::Util qw( blessed );

Moose::Exporter->setup_import_methods(
    with_meta => [qw( field group )],
);

sub init_meta {
    shift;
    my %p = @_;

    Moose::Util::MetaRole::apply_metaroles(
        for             => $p{for_class},
        class_metaroles => { class => ['Chloro::Trait::Class'] },
        role_metaroles  => {
            role                 => ['Chloro::Trait::Role'],
            application_to_class => ['Chloro::Trait::Application::ToClass'],
            application_to_role  => ['Chloro::Trait::Application::ToRole'],
        },
    );

    if ( Class::MOP::class_of( $p{for_class} )->isa('Moose::Meta::Class') ) {
        Moose::Util::MetaRole::apply_base_class_roles(
            for   => $p{for_class},
            roles => ['Chloro::Role::Form'],
        );
    }

    return;
}

sub field {
    my $meta = shift;

    my $field = Chloro::Field->new(
        name => shift,
        @_,
    );

    # Called inside a call to group()
    if (wantarray) {
        return $field;
    }
    else {
        $meta->add_field($field);
    }

    return;
}

sub group {
    my $meta = shift;

    my @fields;
    push @fields, pop @_ while blessed $_[-1];

    my $group = Chloro::Group->new(
        name   => shift,
        fields => \@fields,
        @_,
    );

    $meta->add_group($group);
}

1;

# ABSTRACT: Form Processing So Easy It Will Knock You Out

__END__

=head1 SYNOPSIS

    package MyApp::Form::Login;

    use Moose;
    use Chloro;

    field username => (
        isa      => 'Str',
        required => 1,
    );

    field password => (
        isa      => 'Str',
        required => 1,
    );

    ...

    sub login {
        ...

        my $form = MyApp::Form::Login->new();

        my $resultset = $form->process( params => $submitted_params );

        if ( $resultset->is_valid() ) {
            my $login = $resultset->results_as_hash();

            # Do something with $login->{username} & $login->{password}
        }
        else {
            # Errors that are not specific to just one field
            my @form_errors = $resultset->form_errors();

            # Errors keyed by specific field names
            my %field_errors = $resultset->field_errors();

            # Do something with these errors
        }
    }

=head1 DESCRIPTION

B<This software is still very alpha, and the API may change without warning in
future versions.>

For a walkthrough of all this module's features, see L<Chloro::Manual>.

Chloro is yet another in a long line of form processing libraries. It differs
from other libraries in that it is entirely focused on defining forms in
programmer terms. Field types are Moose type constraints, not HTML widgets
("Str" not "Select").

Chloro is focused on taking a browser's submission, doing basic validation,
and returning a data structure that you can use for further processing.

Out of the box, it does not talk to your database, nor does it know anything
about rendering HTML. However, it is designed so that these features could be
provided by extensions.

=head1 DEFINING A BASIC FORM

A form is defined as a unique class, so you might have C<MyApp::Form::Login>,
C<MyApp::Form::User>, etc. To make a form class, just C<use Chloro>.

This will make your class a form, and you also get all the exports from Moose,
meaning you can define regular attributes, consume roles, etc.

A form consists of one or more fields. A field is a name plus a data type, as
well as some other optional parameters.

    package MyApp::Form::User;

    use Chloro;

    field username => (
        isa      => 'Str',
        required => 1,
    );

    field email_address => (
        isa      => 'EmailAddress',
        required => 1,
    );

    field password => (
        isa    => 'Str',
        secure => 1,
    );

    field password2 => (
        isa    => 'Str',
        secure => 1,
    );

    sub _validate_form {
        my $self   = shift;
        my $params = shift;

        # Use a bare return if form is valid.
        return if ...;

        # Check that passwords are the same. Maybe check that password is
        # present if required. Return a list of error messages.

        return 'The two password fields must match.';
    }

=head1 FIELDS

A field requires a name and a type. The type is defined as a Moose type
constraint, not as an HTML widget type. So for example, a field can be a
C<Str>, C<Int>, C<ArrayRef[Int]>, or a L<DateTime>.

Field values are extracted from the user-submitted params for processing. By
default, the extractor looks for a key matching the field's name, but you can
define your own extraction logic. For example, you could define a L<DateTime>
field that looked for three separate keys, C<day>, C<month>, C<year>, and used
those to construct a L<DateTime> object.

Fields are declared with the C<field()> subroutine exported by Chloro. This
subroutine allows the following parameters:

=over 4

=item * isa

This must be a L<Moose> type constraint. This can be passed as a string, a
type constraint object, or as a L<MooseX::Types> type.

This type will be used to validate the field when it is submitted.

=item * default

The default value for the field. This can either be a non-reference scalar, or
a subroutine reference.

If this is a subroutine reference, it will be called as a method on the field
object. It will also receive the parameters being processed and the field
prefix as arguments.

Field prefixes only matter for field groups, which are documented later.

=item * required

A field can be made required. If a required field is missing, the form
submission is not valid.

=item * secure

XXX - do something with this

=item * extractor

This is a subroutine reference that defines how the field's value is extracted
from the hash reference of parameters that a form processes.

This subroutine will be called as a method on the L<Chloro::Field> object
itself. It will receive three additional parameters.

The first is a string containing the field's expected name in the
parameters. For a simple field, this is the same as the field's name. For a
field in a group, this key includes a prefix to uniquely identify that field.

The second parameter is the hash reference of data submitted to the form. The
third parameter is the form object itself.

By default, the extractor simply return the given from the form data. You can
override this to implement a more complex extraction strategy. For example,
you might extract a date from three separate field (year, month, day).

=item * validator

This is a subroutine reference that defines how the field's value is validated.

This subroutine will be called as a method on the L<Chloro::Field> object
itself. It will receive three additional parameters.

The first is the value being validated. The second parameter is the hash
reference of data submitted to the form. The third parameter is the form
object itself.

By default, this simply uses the field's associated
L<Moose::Meta::TypeConstraint> object to do validation, but you can add
additional logic here. For example, you could validate that a start date is
earlier than an end date.

=back
