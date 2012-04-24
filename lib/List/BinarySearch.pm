package List::BinarySearch;

use strict;
use warnings;

use Scalar::Util qw( looks_like_number );


require Exporter;
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( bsearch_array bsearch_list );
our %EXPORT_TAGS = ( all => [ qw( bsearch_array bsearch_list ) ] );


=head1 NAME

List::BinarySearch - Binary Search a sorted list or array.

=head1 VERSION

Version 0.01_001
Developer's Release

=cut

our $VERSION = '0.01_001';
$VERSION = eval $VERSION; ## no critic (eval)


=head1 SYNOPSIS

This module performs a binary search on an array passed by reference, or on
an array or list passed as a flat list.

The binary search algorithm implemented in this module provides stable
searches (deferred detection).  Stable binary search algorithms have the
following characteristics, contrasted with their unstable binary search
cousins:

=over 4

=item * In the case of non-unique keys, a stable binary search will
always return the lowest-indexed matching element.  An unstable binary search
would return the first one found, which may not be the chronological first.

=item * Best and worst case time complexity is always O(log n).  Unstable
searches may find the target in fewer iterations in the best case, but in the
worst case would still be O(log n).

=item * Stable binary searches only require one relational comparison per
iteration, where unstable binary searches require two conditionals per
iteration.

=item * The net result is that although an unstable binary search might have
a better "best case" time complexity, the fact that a stable binary search
gets away with fewer comparisons per iteration gives it better performance
in the worst case, and approximately equal performance in the average case.
By trading away slightly better "best case" performance, the stable search
gains the guarantee that the element found will always be the lowest-indexed
element in a range of non-unique keys.

=back

Examples:

    use List::BinarySearch qw( bsearch_array bsearch_list );

    my @array = ( 100, 200, 300, 400, 500 );
    my $index;

    # Search an array passed by reference.
    $index = bsearch_array( \@array, $target );

    # Search an array passed by reference, using a custom comparator.
    $index = bsearch_array( \@array, $target, sub { $_[0] cmp $_[1] } );

    # Search an array passed as a flat list.
    $index = bsearch_list( $target, @array );

    # Search an array passed as a flat list, using a custom comparator.
    $index = bsearch_list( $sub{ $_[0] cmp $_[1] }, $target, @array );

    # Returns undef:
    $index = bsearch_array( \@array, 250 );  # 250 isn't found in @array.


=head1 EXPORT

Nothing is exported by default.  Upon request will export C<bsearch_array>,
C<bsearch_list>, or both functions by specifying C<:all>.

=head1 RATIONALE

Before using this module the user should weigh the other options: linear
searches ( C<grep> or C<List::Util::first> ), or hash based searches.
A binary search only makes sense if the data set is already sorted in
ascending order, and if it is determined that the cost of a linear search, or
the linear-time conversion to a hash-based container is too inefficient.  So
often, it just doesn't make sense to try to optimize beyond what Perl's tools
natively provide.

However, in some cases, a binary search can be an excellent choice.  Finding
the first matching element in a list of 1,000,000 items with a linear search
would have a worst-case of 1,000,000 iterations, whereas the worst case for
a binary search of 1,000,000 elements is about 20 iterations.


=head1 SUBROUTINES/METHODS

=head2 bsearch_array

    $first_found_ix = bsearch_array( $array_ref, $target );
    $first_found_ix = bsearch_array( $array_ref, $target, \&comparator );

Pass a reference to an array to be searched, a target item to find, and
optionally a reference to a comparator subroutine.

If no comparator is passed, the search algorithm will try to determine if
C<$target> looks like a number or like a string.  If C<$target> looks like a
number, the default search will use numeric comparison.  If C<$target> doesn't
look like a number, the default search will use string comparison.

Internally Scalar::Util::looks_like_number is used to decide whether to use
numeric or stringwise comparisons in the absence of an explicit comparator
subroutine.

Return value is the index of the first element equalling C<$target>.  If no
element is found, undef is returned.

=cut

sub bsearch_array {
    my( $aref, $target, $code ) = @_;
    $code //= looks_like_number( $target ) ?
        sub { $_[0] <=> $_[1] }            :
        sub { $_[0] cmp $_[1] };

    my $min = 0;
    my $max = $#{$aref};
    while( $max > $min ) {
        my $mid = int( ( $min + $max ) / 2 );
        if( $code->( $target, $aref->[$mid] ) > 0 ) {
            $min = $mid + 1;
        }
        else {
            $max = $mid;
        }
    }
    return $min
        if $max == $min && $code->( $target, $aref->[$min] ) == 0;
    return;  # Undef in scalar context, empty list in list context.
}


=head2 bsearch_list

    $first_found_ix = bsearch_list( $target, @list );
    $first_found_ix = bsearch_list( \&comparator, $target, @list );

Pass an optional reference to a comparator subroutine, a target, and a flat
list to be searched.

If no comparator is passed, the search algorithm will try to determine if
C<$target> looks like a number or like a string.  If C<$target> looks like a
number, the default search will use numeric comparison.  If C<$target> doesn't
look like a number, the default search will use string comparison.

Internally Scalar::Util::looks_like_number is used to decide whether to
default to numeric or stringwise comparisons in the absence of an explicit
comparator subroutine.

Return value is the index of the first element equalling C<$target>.  If no
element is found, undef is returned.

=cut

sub bsearch_list {
    my $code;
    if( ref $_[0] =~ /CODE/ ) {
        $code = shift
    }
    my $target = shift;
    return bsearch_array( \@_, $target, $code );
}


=head2 \&comparator
(callback)

Comparators are references to functions that accept as parameters a target,
and a list element, returning the result of the relational comparison of the
two values.  A good example would be the code block in a C<sort> function,
except that our comparators get their input from C<@_>, where C<sort>'s
comparator functions get their input from C<$a> and C<$b>.


The default comparators are defined like this:

    # Numeric comparisons:
    $comp = sub {
        my( $target, $list_item ) = @_;
        return $target <=> $list_item;
    };

    # Non-numeric (stringwise) comparisons:
    $comp = sub {
        my( $target, $list_item ) = @_;
        return $target cmp $list_item;
    };

Optionally the user may supply a custom comparator to override default
comparison logic.  A custom comparator function should return:

    -1 if $target <  $list_item
     0 if $target == $list_item
     1 if $target >  $list_item

=cut

=head1 DATA SET REQUIREMENTS

A well written general algorithm should place as few demands on its data as
practical.  The two requirements that these Binary Search algorithms impose
are:

=over 4

=item * The lists must be in ascending sorted order.

This is a big one.  Keep in mind that the best sort routines run in O(n log n)
time.  It makes no sense to sort a list in O(n log n), and then perform a
single O(log n) binary search when List::Util C<first> could accomplish the
same thing in O(n) time.  A Binary Search only makes sense if there are other
good reasons for keeping the data set sorted in the first place.

=item * Passing an unsorted list to these Binary Search algorithms will result
in undefined behavior.

A Binary Search consumes O(log n) time.  It would, therefore, be foolish for
these algorithms to pre-check the list for sortedness, as that would require
linear, or O(n) time.  Since no sortedness testing is done, there can be no
guarantees as to what will happen if an unsorted list is passed to a binary
search.

=item * Data that is more complex than simple numeric or string lists will
require a custom comparator.

=back

=head1 AUTHOR

David Oswald, C<< <davido at cpan.org> >>

If the documentation fails to answer your question, or if you have a comment
or suggestion, send me an email.

=head1 BUGS

This is an early developer's release.  The API can (and probably will) change.
Version numbers in this format: C<x.xx_xxx> are dev releases.
Version numbers in this format: C<x.xx> are stable.

Please report any bugs or feature requests to
C<bug-list-binarysearch at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=List-BinarySearch>.  I will
be notified, and then you'll automatically be notified of progress on your bug
as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc List::BinarySearch

You can also look for information at:

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


=head1 LICENSE AND COPYRIGHT

Copyright 2012 David Oswald.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of List::BinarySearch
