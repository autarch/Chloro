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
use List::AllUtils qw( all );
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
    } $self->_validate_form( $params, \%results );

    return $self->_make_resultset( $params, \%results, \@form_errors );
}

sub _make_resultset {
    my $self        = shift;
    my $params      = shift;
    my $results     = shift;
    my $form_errors = shift;

    return $self->_resultset_class()->new(
        params      => $params,
        results     => $results,
        form_errors => $form_errors,
    );
}

sub _resultset_class {
    return 'Chloro::ResultSet';
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

    # A missing boolean should be treated as false (an unchecked checkbox does
    # not show up in user-submitted parameters).
    if ( _value_is_empty($value) ) {
        if ( $field->type()->is_a_type_of('Bool') ) {
            $value = 0;
        }
        elsif ( ! $field->is_required() ) {
            return;
        }
    }

    my $validator = $field->validator();

    my @errors;
    if ( $field->is_required() && _value_is_empty($value) ) {
        push @errors,
            Chloro::ErrorMessage::Missing->new(
            message => 'The ' . $field->human_name() . ' field is required.' );
    }
    else {

        # The validate() method returns false on valid (bah)
        if ( $field->type()->validate($value) ) {

            # XXX - we are ignoring the Moose-returned message for now, because
            # it's not at all end user friendly.
            push @errors,
                Chloro::ErrorMessage::Invalid->new( message => 'The '
                    . $field->human_name()
                    . ' field did not contain a valid value.' );
        }
        elsif ( my $msg
            = $self->$validator( $value, $params, $prefix, $field ) ) {

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
    # my $prefix = shift;
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

    my $checker = $group->is_empty_checker();
    return if $self->$checker( $params, $prefix, $group );

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

sub group_is_empty {
    my $self   = shift;
    my $params = shift;
    my $prefix = shift;
    my $group  = shift;

    return all { !( defined $params->{$_} && length $params->{$_} ) }
    map { join q{.}, $prefix, $_->name() } $group->fields();
}

sub _validate_form { }

sub _value_is_empty {
    return defined $_[0] && length $_[0] ? 0 : 1;
}

1;
