package Chloro::Role::Form;

use Moose::Role;

use namespace::autoclean;

use Chloro::ErrorMessage::Invalid;
use Chloro::ErrorMessage::Missing;
use Chloro::Result::Field;
use Chloro::Result::Group;
use Chloro::ResultSet;
use Chloro::Types qw( HashRef );
use MooseX::Params::Validate qw( validated_list );

sub fields {
    my $self = shift;

    return $self->meta()->fields();
}

sub process {
    my $self = shift;
    my ($params) = validated_list(
        \@_,
        params => { isa => HashRef },
    );

    my %results;
    for my $field ( $self->fields() ) {
        $results{ $field->name() } =
            $self->_result_for_field($field, $params);
    }

    my @form_errors = $self->_validate_form($params);

    return Chloro::ResultSet->new(
        results     => \%results,
        form_errors => \@form_errors,
    );
}

sub _result_for_field {
    my $self   = shift;
    my $field  = shift;
    my $params = shift;

    my ( $value, @errors ) = $self->_validate_field( $field, $params );

    @errors
        = map { Chloro::Error::Field->new( field => $field, error => $_ ) }
        @errors;

    return Chloro::Result::Field->new(
        field  => $field,
        errors => \@errors,
        ( defined $value ? ( value => $value ) : () ),
    );
}

sub _validate_field {
    my $self   = shift;
    my $field  = shift;
    my $params = shift;

    my $value = $field->extractor()->( $field, $params, $self );
    $value = $field->default() if !defined $value && $field->has_default();

    my @errors;
    if ( $field->is_required() && _value_is_empty($value) ) {
        push @errors,
            Chloro::ErrorMessage::Missing->new(
            message => 'The ' . $field->name() . ' field is required.' );
    }
    elsif ( my $msg
        = $field->validator()->( $field, $value, $params, $self ) ) {

        # XXX - we are ignoring the Moose-returned message for now, because
        # it's not at all end user friendly.
        push @errors,
            Chloro::ErrorMessage::Invalid->new( message => 'The '
                . $field->name()
                . ' field did not contain a valid value.' );
    }

    return ( $value, @errors );
}

sub _validate_form { }

sub _value_is_empty {
    return defined $_[0] && $_[0] ne q{} ? 0 : 1;
}

1;
