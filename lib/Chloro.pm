package Chloro;

use strict;
use warnings;

our $VERSION = '0.01';

use Chloro::Field;
use Chloro::Role::Meta::Class;
use Moose::Exporter;
use Moose::Meta::Class;

Moose::Exporter->setup_import_methods
    ( with_caller => [ qw( fieldset group field dependency ) ],
    );


sub init_meta
{
    shift;
    my %p = @_;

    Moose->init_meta( %p, base_class => 'Chloro::Object' );

    return
        Moose::Util::MetaRole::apply_metaclass_roles
            ( for_class       => $p{for_class},
              metaclass_roles => [ 'Chloro::Role::Meta::Class' ],
            );
}

sub fieldset
{
    my $caller = shift;
    my $name   = shift;

    my $fieldset = Chloro::FieldSet->new( name => $name );

    Moose::Meta::Class
        ->initialize($caller)
        ->form()
        ->add_fieldset($fieldset);
}

sub group
{
    my $caller = shift;
    my $name   = shift;

    my $group = Chloro::FieldGroup->new( name => $name );

    Moose::Meta::Class
        ->initialize($caller)
        ->form()
        ->add_field_group($group);
}

sub field
{
    my $caller = shift;
    my $name   = shift;

    Moose::Meta::Class
        ->initialize($caller)
        ->form()
        ->add_field( Chloro::Field->new( name => $name, @_ ) );

    return;
}

sub include
{
    my $caller = shift;
    my $thing  = shift;

    my @sets;
    if ( ref $thing )
    {
        @sets = $thing->fieldsets();
    }
    else
    {
        Class::MOP::load_class($thing);
        @sets = $thing->form()->fieldsets();
    }

    my $meta = Moose::Meta::Class->initialize($caller);
    $meta->form()->add_fieldset($_) for @sets;
}

sub dependency
{
    my $caller = shift;
    my $name   = shift;

    Moose::Meta::Class
        ->initialize($caller)
        ->form()
        ->add_dependency(@_);

    return;
}

1;

__END__

=pod

=head1 NAME

Chloro - The fantastic new Chloro!

=head1 SYNOPSIS

XXX - change this!

    use Chloro;

    my $foo = Chloro->new();

    ...

=head1 DESCRIPTION

=head1 METHODS

This class provides the following methods

=head1 AUTHOR

Dave Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-chloro@rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org>.  I will be
notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
