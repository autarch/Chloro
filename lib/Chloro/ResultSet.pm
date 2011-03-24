package Chloro::ResultSet;

use Moose;

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

sub results_hash {
    my $self = shift;

    my %hash;

    for my $result ( $self->_result_values() ) {
        if ( $result->can('group') ) {
            $hash{ $result->group()->name() }{ $result->key() }
                = { $result->key_value_pairs() };

            $hash{ $result->group()->repetition_field() }
                = $self->_params()->{ $result->group()->repetition_field() };
        }
        else {
            %hash = ( %hash, $result->key_value_pairs() );
        }
    }

    return %hash;
}

__PACKAGE__->meta()->make_immutable();

1;
