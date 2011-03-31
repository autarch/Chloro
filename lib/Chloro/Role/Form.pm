package Chloro::Role::Form;

use Moose::Role;

use namespace::autoclean;

use Chloro::Error::Form;
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

sub groups {
    my $self = shift;

    return $self->meta()->groups();
}

sub process {
    my $self = shift;
    my ($params) = validated_list(
        \@_,
        params => { isa => HashRef },
    );

    my %results;
    for my $field ( $self->fields() ) {
        $results{ $field->name() }
            = $self->_result_for_field( $field, $params );
    }

    for my $group ( $self->groups() ) {
        for my $result ( $self->_results_for_group( $group, $params ) ) {
            $results{ $result->prefix() } = $result;
        }
    }

    my @form_errors = map {
        Chloro::Error::Form->new(
            error => ref $_
            ? $_
            : Chloro::ErrorMessage::Invalid->new( message => $_ )
            )
    } $self->_validate_form($params);

    return Chloro::ResultSet->new(
        params      => $params,
        results     => \%results,
        form_errors => \@form_errors,
    );
}

sub _result_for_field {
    my $self   = shift;
    my $field  = shift;
    my $params = shift;
    my $prefix = shift;

    my ( $value, @errors )
        = $self->_validate_field( $field, $params, $prefix );

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
    my $prefix = shift;

    my $extractor = $field->extractor();
    my $value = $self->$extractor( $params, $prefix, $field );

    $value = $field->generate_default( $params, $prefix )
        if !defined $value && $field->has_default();

    return if _value_is_empty($value) && ! $field->is_required();

    my $validator = $field->validator();

    my @errors;
    if ( $field->is_required() && _value_is_empty($value) ) {
        push @errors,
            Chloro::ErrorMessage::Missing->new(
            message => 'The ' . $field->name() . ' field is required.' );
    }
    else {

        # The validate() method returns false on valid (bah)
        if ( $field->type()->validate($value) ) {

            # XXX - we are ignoring the Moose-returned message for now, because
            # it's not at all end user friendly.
            push @errors,
                Chloro::ErrorMessage::Invalid->new( message => 'The '
                    . $field->name()
                    . ' field did not contain a valid value.' );
        }
        elsif ( my $msg = $self->$validator( $value, $params, $field ) ) {
            push @errors,
                Chloro::ErrorMessage::Invalid->new( message => $msg );

        }
    }

    return ( $value, @errors );
}

sub extract_field_value {
    my $self   = shift;
    my $params = shift;
    my $prefix = shift;
    my $field  = shift;

    my $key = join q{.}, grep {defined} $prefix, $field->name();

    return $params->{$key};
}

sub errors_for_field_value {
    # my $self   = shift;
    # my $value  = shift;
    # my $params = shift;
    # my $field  = shift;

    return;
}

sub _results_for_group {
    my $self   = shift;
    my $group  = shift;
    my $params = shift;

    my $keys = $params->{ $group->repetition_field() };

    return
        map { $self->_result_for_group_by_key( $group, $params, $_ ) }
        grep { defined && length }
        ref $keys ? @{$keys} : $keys;
}

sub _result_for_group_by_key {
    my $self   = shift;
    my $group  = shift;
    my $params = shift;
    my $key    = shift;

    my $prefix = join q{.}, $group->name(), $key;

    return unless $group->has_data_in_params( $params, $prefix, $self );

    my %results;
    for my $field ( $group->fields() ) {
        $results{ $field->name() }
            = $self->_result_for_field( $field, $params, $prefix );
    }

    return Chloro::Result::Group->new(
        group   => $group,
        key     => $key,
        prefix  => $prefix,
        results => \%results,
    );
}

sub _validate_form { }

sub _value_is_empty {
    return defined $_[0] && length $_[0] ? 0 : 1;
}

1;
