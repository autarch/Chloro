package Chloro::FieldTypes;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw( NonEmptyStr PosInt PosOrZeroInt PosNum PosOrZeroNum Bool );
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

use Chloro::FieldType;
use Chloro::Types
    ( map { $_ => { -as => 'CT_' . $_ } }
      qw( NonEmptyStr PosInt PosOrZeroInt PosNum PosOrZeroNum ) );
use MooseX::Types::Moose ( Bool => { -as => 'MooseBool' } );

use constant { NonEmptyStr  => Chloro::FieldType->new( type => CT_NonEmptyStr ),
               PosInt       => Chloro::FieldType->new( type => CT_PosInt ),
               PosOrZeroInt => Chloro::FieldType->new( type => CT_PosOrZeroInt ),
               PosNum       => Chloro::FieldType->new( type => CT_PosNum ),
               PosOrZeroNum => Chloro::FieldType->new( type => CT_PosOrZeroNum ),
               Bool         => Chloro::FieldType->new( type => MooseBool ),
             };

1;
