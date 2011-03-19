package Chloro::Types;

use strict;
use warnings;
use namespace::autoclean;

use base 'MooseX::Types::Combine';

__PACKAGE__->provide_types_from(
    qw(
        MooseX::Types::Common::String
        MooseX::Types::Moose
        MooseX::Types::Path::Class
        Chloro::Types::Internal
        )
);
