## no critic (RCS,prototypes)

package List::BinarySearch::PP;

use strict;
use warnings;

require Exporter;

# There is much debate on whether to use base, parent, or manipulate @ISA.
# The lowest common denominator is what belongs in modules, we'll do @ISA.

our @ISA    = qw(Exporter);    ## no critic (ISA)
our @EXPORT = qw( binsearch binsearch_pos ); ## no critic (export)


our $VERSION = '0.011_002';
$VERSION = eval $VERSION;  ## no critic (eval)



#---------------------------------------------
# Use a callback for comparisons.

sub binsearch (&$\@) {
    my ( $code, $target, $aref ) = @_;
    my $min = 0;
    my $max = $#{$aref};
    while ( $max > $min ) {
        my $mid = int( ( $min + $max ) / 2 );
        no strict 'refs'; ## no critic(strict)
        local ( ${caller() . '::a'}, ${caller() . '::b'} )
          = ( $target, $aref->[$mid] );                            # Future use.
        if ( $code->( $target, $aref->[$mid] ) > 0 ) {
            $min = $mid + 1;
        }
        else {
            $max = $mid;
        }
    }
    {
      no strict 'refs'; ## no critic(strict)
      local ( ${caller() . '::a'}, ${caller() . '::b'} )
        = ( $target, $aref->[$min] );                              # Future use.
      return $min
        if $max == $min && $code->( $target, $aref->[$min] ) == 0;
    }
    return;    # Undef in scalar context, empty list in list context.
}


#------------------------------------------------------
# Identical to binsearch, but upon match-failure returns best insert
# position for $target.


sub binsearch_pos (&$\@) {
    my ( $comp, $target, $aref ) = @_;
    my ( $low, $high ) = ( 0, scalar @{$aref} );
    while ( $low < $high ) {
        my $cur = int( ( $low + $high ) / 2 );
        no strict 'refs';  ## no critic(strict)
        local ( ${ caller() . '::a'}, ${ caller() . '::b'} )
          = ( $target, $aref->[$cur] );                            # Future use.
        if ( $comp->( $target, $aref->[$cur] ) > 0 ) {
            $low = $cur + 1;
        }
        else {
            $high = $cur;
        }
    }
    return $low;
}


1;

__END__

=head1 NAME

List::BinarySearch::PP - Pure-Perl Binary Search functions.


=head1 SYNOPSIS

This module is a (default) plugin for List::BinarySearch.  It is provided by
the L<List::BinarySearch> distribution.

Examples:


    use List::BinarySearch qw( binsearch  binsearch_pos  binsearch_range );

    @num_array =   ( 100, 200, 300, 400, 500 );
    @str_array = qw( Bach Beethoven Brahms Mozart Schubert );


    # Find the lowest index of a matching element.

    $index = binsearch {$a <=> $b} 300, @num_array;
    $index = binsearch {$a cmp $b} 'Mozart', @str_array;      # Stringy cmp.
    $index = binsearch {$a <=> $b} 42, @num_array;            # not found: undef

    # Find the lowest index of a matching element, or best insert point.

    $index = binsearch_pos {$a cmp $b} 'Chopin', @str_array;  # Insert at [3].
    $index = binsearch_pos 600, @num_array;                   # Insert at [5].

    splice @num_array, $index, 1, 600
      if( $num_array[$index] != 600 );                        # Insertion at [5]

    $index = binsearch_pos { $a <=> $b } 200, @num_array;     # Matched at [1].


=head1 DESCRIPTION

This module provides pure-Perl implementations of the C<binsearch> and
C<binsearch_pos> functions for use by L<List::BinarySearch>.  Please refer to
the documentation for L<List::BinarySearch> for a full description of those
functions.


=head1 EXPORT

List::BinarySearch::PP exports by default C<binsearch> and C<binsearch_pos>.

=head1 SUBROUTINES/METHODS

=head2 binsearch CODE NEEDLE ARRAY_HAYSTACK

    $first_found_ix = binsearch { $a cmp $b } $needle, @haystack;

Uses the supplied code block as a comparator to search for C<$needle> within
C<@haystack>.  If C<$needle> is found, return value will be the lowest index of
a matching element, or C<undef> if the needle isn't found.

=head2 binsearch_pos CODE NEEDLE ARRAY_HAYSTACK

    $first_found_ix = binsearch_pos { $a cmp $b } $needle, @haystack;

Uses the supplied code block as a comparator to search for C<$needle> within
C<@haystack>. If C<$needle> is found, return value will be the lowest index of
a matching element, or the index of the best insertion point for the needle if
it isn't found.


=head1 CONFIGURATION AND ENVIRONMENT

Perl 5.8.0 or newer required.  This module is part of the L<List::BinarySearch>
distribution, and is intended for use by the C<List::BinarySearch> module.
It shouldn't be directly used by code outside of this distribution.

=head1 DEPENDENCIES

This module uses L<Exporter|Exporter>.


=head1 INCOMPATIBILITIES

Perl versions prior to 5.8.0 aren't officially supported by this distribution.
The pure-Perl module, C<List::BinarySearch::PP> is probably Perl 5.6
compatible, but hasn't been smoke-tested on any Perl prior to 5.8.


=head1 AUTHOR

David Oswald, C<< <davido at cpan.org> >>

If the documentation fails to answer your question, or if you have a comment
or suggestion, send me an email.


=head1 DIAGNOSTICS


=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-list-binarysearch at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=List-BinarySearch>.  I will
be notified, and then you'll automatically be notified of progress on your bug
as I make changes.



=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc List::BinarySearch

This module is maintained in a public repo at Github.  You may look for
information at:

=over 4

=item * Github: Development is hosted on Github at:

L<http://www.github.com/daoswald/List-BinarySearch>

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=List-BinarySearch>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/List-BinarySearch>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/List-BinarySearch>

=item * Search CPAN

L<http://search.cpan.org/dist/List-BinarySearch/>

=back


=head1 ACKNOWLEDGEMENTS

L<Mastering Algorithms with Perl|http://shop.oreilly.com/product/9781565923980.do>,
from L<O'Reilly|http://www.oreilly.com>: for the inspiration (and much of the
code) behind the positional search.  Quoting MAwP: "I<...the binary search was
first documented in 1946 but the first algorithm that worked for all sizes of
array was not published until 1962.>" (A summary of a passage from Knuth:
Sorting and Searching, 6.2.1.)


=head1 LICENSE AND COPYRIGHT

Copyright 2013 David Oswald.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
