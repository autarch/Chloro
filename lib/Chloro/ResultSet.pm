package Chloro::ResultSet;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;

use Chloro::Error::Form;
use Chloro::Types qw( ArrayRef Bool HashRef );
use List::AllUtils qw( any );

with 'Chloro::Role::ResultSet';

has _form_errors => (
    traits   => ['Array'],
    isa      => ArrayRef ['Chloro::Error::Form'],
    init_arg => 'form_errors',
    required => 1,
    handles  => {
        form_errors      => 'elements',
        _has_form_errors => 'count',
    },
);

has _params => (
    is       => 'ro',
    isa      => HashRef,
    init_arg => 'params',
    required => 1,
);

has is_valid => (
    is       => 'ro',
    isa      => Bool,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_is_valid',
);

sub _build_is_valid {
    my $self = shift;

    return 0 if $self->_has_form_errors();

    return 0 if any { ! $_->is_valid() } $self->_result_values();

    return 1;
}

sub results_as_hash {
    my $self = shift;

    return $self->_results_hash();
}

sub secure_results_as_hash {
    my $self = shift;

    return $self->_results_hash('skip secure');
}

sub _results_hash {
    my $self        = shift;
    my $skip_secure = shift;

    my %hash;

    for my $result ( $self->_result_values() ) {
        if ( $result->can('group') ) {
            $hash{ $result->group()->name() }{ $result->key() }
                = { $result->key_value_pairs($skip_secure) };

            my $rep_vals
                = $self->_params()->{ $result->group()->repetition_field() };

            $hash{ $result->group()->repetition_field() }
                = ref $rep_vals ? $rep_vals : [$rep_vals];
        }
        else {
            next if $skip_secure && $result->field()->is_secure();

            %hash = ( %hash, $result->key_value_pairs() );
        }
    }

    return \%hash;
}

sub field_errors {
    my $self = shift;

    my %errors;
    for my $result ( grep { !$_->is_valid() } $self->_result_values() ) {
        if ( $result->can('group') ) {
            for my $field_result ( grep { !$_->is_valid() }
                $result->_result_values() ) {

                my $key = join q{.}, $result->prefix(),
                    $field_result->field()->name();

                $errors{$key} = [ $field_result->errors() ];
            }
        }
        else {
            $errors{ $result->field()->name() } = [ $result->errors() ];
        }
    }

    return %errors;
}

sub all_errors {
    my $self = shift;

    my %field_errors = $self->field_errors();

    return $self->form_errors(), map { @{$_} } values %field_errors;
}

__PACKAGE__->meta()->make_immutable();

1;
