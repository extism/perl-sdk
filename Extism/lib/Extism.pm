package Extism;

use 5.006;
use strict;
use warnings;
use Extism::XS qw(version log_file);
use Extism::Plugin;
use Extism::Function ':all';
use Exporter 'import';

sub log_custom {
  my ($level) = @_;
  return Extism::XS::log_custom($level);
}

sub log_drain {
  my ($func) = @_;
  local *Extism::active_log_drain_func = $func;
  return Extism::XS::log_drain();
}

our @EXPORT_OK = qw(
  Extism_I32
  Extism_I64
  Extism_F32
  Extism_F64
  Extism_V128
  Extism_FuncRef
  Extism_ExternRef
  Extism_String
);

our %EXPORT_TAGS;
$EXPORT_TAGS{all} = [@EXPORT_OK];

=head1 NAME

Extism - The great new Extism!

=head1 VERSION

Version 0.01

=cut

use version 0.77; our $VERSION = qv(v0.0.1);


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Extism;

    my $foo = Extism->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Gavin Hayes, C<< <gavin at dylibso.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-extism at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Extism>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Extism


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Extism>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Extism>

=item * Search CPAN

L<https://metacpan.org/release/Extism>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2024 by Dylibso.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=cut

1; # End of Extism
