## no critic (RCS,prototypes)

package List::BinarySearch;

use 5.006000;
use strict;
use warnings;
use Carp;

use Scalar::Util qw( looks_like_number );


BEGIN {

  my @imports = qw( binsearch binsearch_pos );

  # Import XS by default, pure-Perl if XS is unavailable, or if
  # $ENV{List_BinarySearch_PP} is set.
  if (
       $ENV{List_BinarySearch_PP}
    || ! eval 'use List::BinarySearch::XS @imports; 1;'  ## no critic (eval)
  ) {
    eval 'use List::BinarySearch::PP  @imports;';        ## no critic (eval)
  }

}

require Exporter;

# There is much debate on whether to use base, parent, or manipulate @ISA.
# The lowest common denominator is what belongs in modules, we'll do @ISA.

our @ISA       = qw(Exporter);    ## no critic (ISA)

# Note: binsearch and binsearch_pos come from List::BinarySearch::PP
our @EXPORT_OK = qw(
  binsearch         binsearch_pos       binsearch_range

  bsearch_str       bsearch_str_pos     bsearch_str_range
  bsearch_num       bsearch_num_pos     bsearch_num_range
  bsearch_custom    bsearch_custom_pos  bsearch_custom_range
  bsearch_transform
);

our %EXPORT_TAGS = ( all => \@EXPORT_OK );

# The prototyping gives List::BinarySearch a similar feel to List::Util,
# and List::MoreUtils.

our $VERSION = '0.12';

# Needed for developer's releases: See perlmodstyle.
# $VERSION = eval $VERSION;    ## no critic (eval,version)

# There is some repetition in the code.  This is an intentional means of
# favoring a small amount of computational efficiency over concise code by
# avoiding unnecessary function call overhead.


# DEPRECATED -----------------------------------

# Search using stringwise comparisons.  Return an index on success, undef or
# an empty list (depending on context) upon failure.

sub bsearch_str ($\@) {
    my( $target, $aref ) = @_;
    my $min = 0;
    my $max = $#{$aref};
    while ( $max > $min ) {
        my $mid = int( ( $min + $max ) / 2 );
        if ( $target gt $aref->[$mid] ) {
            $min = $mid + 1;
        }
        else {
            $max = $mid;
        }
    }

    return $min
      if $max == $min && $target eq $aref->[$min];

    return;
}
#---------------------------------------------

# Search using numeric comparisons.
# DEPRECATED ---------------------------------
sub bsearch_num ($\@) {
    my ( $target, $aref ) = @_;
    my $min = 0;
    my $max = $#{$aref};
    while ( $max > $min ) {
        my $mid = int( ( $min + $max ) / 2 );
        if ( $target > $aref->[$mid] ) {
            $min = $mid + 1;
        }
        else {
            $max = $mid;
        }
    }
    return $min
      if $max == $min && $target == $aref->[$min];
    return;    # Undef in scalar context, empty list in list context.
}



# DEPRECATED -------------------------------
sub bsearch_custom(&$\@);
*bsearch_custom = \&binsearch;
# ------------------------------------------

# Use a callback to transform the list elements before comparing.  Comparisons
# will be stringwise or numeric depending on what target looks like.

# DEPRECATED -------------------------------
sub bsearch_transform (&$\@) {
    my ( $transform_code, $target, $aref ) = @_;
    my ( $min, $max ) = ( 0, $#{$aref} );

    if ( looks_like_number $target ) {
        while ( $max > $min ) {
            my $mid = int( ( $min + $max ) / 2 );
            if ( $target > $transform_code->( $aref->[$mid] ) ) {
                $min = $mid + 1;
            }
            else {
                $max = $mid;
            }
        }
        return $min
          if $max == $min && $target == $transform_code->( $aref->[$min] );
    }
    else {
        while ( $max > $min ) {
            my $mid = int( ( $min + $max ) / 2 );
            if ( $target gt $transform_code->( $aref->[$mid] ) ) {
                $min = $mid + 1;
            }
            else {
                $max = $mid;
            }
        }
        return $min
          if $max == $min && $target eq $transform_code->( $aref->[$min] );
    }

    return;    # Undef in scalar context, empty list in list context.
}

# ----------------------------------------------------
# Virtually identical to bsearch_str, but upon match-failure returns best
# insert position for $target.

# DEPRECATED ------------------------------------------
sub bsearch_str_pos ($\@) {
    my ( $target, $aref ) = @_;
    my ( $low, $high ) = ( 0, scalar @{$aref} );
    while ( $low < $high ) {
        use integer;
        my $cur = ( $low + $high ) / 2;
        if ( $target gt $aref->[$cur] ) {
            $low = $cur + 1;    # too small, try higher
        }
        else {
            $high = $cur;       # not too small, try lower
        }
    }
    return $low;
}
#------------------------------------------------------

# Identical to bsearch_num, but upon match-failure returns best insert
# position for $target.

# DEPRECATED ------------------------------------------
sub bsearch_num_pos ($\@) {
    my ( $target, $aref ) = @_;
    my ( $low, $high ) = ( 0, scalar @{$aref} );
    while ( $low < $high ) {
        my $cur = int( ( $low + $high ) / 2 );
        if ( $target > $aref->[$cur] ) {
            $low = $cur + 1;    # too small, try higher
        }
        else {
            $high = $cur;       # not too small, try lower
        }
    }
    return $low;
}


# DEPRECATED --------------------------------------------
sub bsearch_custom_pos(&$\@);
*bsearch_custom_pos = \&binsearch_pos;
#--------------------------------------------------------

# Given a low and a high target, returns a range of indices representing
# where low and high fit into @haystack.

# DEPRECATED -------------------------------------------
sub bsearch_str_range ($$\@) {
    my ( $low_target, $high_target, $aref ) = @_;
    my $index_low  = bsearch_str_pos( $low_target,  @{$aref} );
    my $index_high = bsearch_str_pos( $high_target, @{$aref} );
    if (   $index_high == scalar @{$aref}
        or $aref->[$index_high] gt $high_target )
    {
        $index_high--;
    }
    return ( $index_low, $index_high );
}
# -----------------------------------------------------


sub binsearch_range (&$$\@) {
  my( $code, $low_target, $high_target, $aref ) = @_;
  my( $index_low, $index_high );

  # Forward along the caller's $a and $b.
  local( *a, *b ) = do{
    no strict 'refs';  ## no critic (strict)
    my $pkg = caller();
    ( *{$pkg.'::a'}, *{$pkg.'::b'} );
  };
  $index_low  = binsearch_pos( \&$code, $low_target,  @$aref );
  $index_high = binsearch_pos( \&$code, $high_target, @$aref );
  local( $a, $b ) = ( $aref->[$index_high], $high_target ); # Use our own.
  if(  $index_high == scalar @$aref    or    $code->( $a, $b ) > 0  )
  {
    $index_high--;
  }
  return ( $index_low, $index_high );
}


# DEPRECATED -------------------------------------------
sub bsearch_custom_range(&$$\@);
*bsearch_custom_range = \&binsearch_range;
# ------------------------------------------------------

# DEPRECATED -------------------------------------------
sub bsearch_num_range ($$\@) {
    my ( $low_target, $high_target, $aref ) = @_;
    my $index_low  = bsearch_num_pos( $low_target,  @{$aref} );
    my $index_high = bsearch_num_pos( $high_target, @{$aref} );
    if (   $index_high == scalar @{$aref}
        or $aref->[$index_high] > $high_target )
    {
        $index_high--;
    }
    return ( $index_low, $index_high );
}

# ------------------------------------------------------


1;    # End of List::BinarySearch

__END__

=head1 NAME

List::BinarySearch - Binary Search within a sorted array.

=head1 SYNOPSIS

This module performs a binary search on an array.

Examples:


    use List::BinarySearch qw( :all );  # ... or ...
    use List::BinarySearch qw( binsearch  binsearch_pos  binsearch_range );


    # Some ordered arrays to search within.
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


    # The following functions return an inclusive range.

    my( $low_ix, $high_ix )
        = binsearch_range { $a cmp $b } 'Beethoven', 'Mozart', @str_array;
        # Returns ( 1, 3 ), meaning ( 1 .. 3 ).

    my( $low_ix, $high_ix )
        = binsearch_range { $a <=> $b } 200, 400, @num_array;



=head1 DESCRIPTION

A binary search searches B<sorted> lists using a divide and conquer technique.
On each iteration the search domain is cut in half, until the result is found.
The computational complexity of a binary search is O(log n).

The binary search algorithm implemented in this module is known as a
I<Deferred Detection> variant on the traditional Binary Search.  Deferred
Detection provides B<stable searches>.  Stable binary search algorithms have
the following characteristics, contrasted with their unstable binary search
cousins:

=over 4

=item * In the case of non-unique keys, a stable binary search will always
return the lowest-indexed matching element.  An unstable binary search would
return the first one found, which may not be the chronological first.

=item * Best and worst case time complexity is always O(log n).  Unstable
searches may stop once the target is found, but in the worst case are still
O(log n).  In practical terms, this difference is usually not meaningful.

=item * Stable binary searches only require one relational comparison of a
given pair of data elements per iteration, where unstable binary searches
require two comparisons per iteration.

=item * The net result is that although an unstable binary search might have
better "best case" performance, the fact that a stable binary search gets away
with fewer comparisons per iteration gives it better performance in the worst
case, and approximately equal performance in the average case. By trading away
slightly better "best case" performance, the stable search gains the guarantee
that the element found will always be the lowest-indexed element in a range of
non-unique keys.

=back

B<< This module has a companion "XS" module: L<List::BinarySearch::XS> which
users are strongly encouraged to install as well. >>  If List::BinarySearch::XS
is also installed, C<binsearch> and C<binsearch_pos> will use XS code.  This
behavior may be overridden by setting C<$ENV{List_BinarySearch_PP}> to a
true value.


=head1 RATIONALE

B<A binary search is pretty simple, right?  Why use a module for this?>

Quoting from
L<Wikipedia|http://en.wikipedia.org/wiki/Binary_search_algorithm>:  I<When Jon
Bentley assigned it as a problem in a course for professional
programmers, he found that an astounding ninety percent failed to code a
binary search correctly after several hours of working on it, and another
study shows that accurate code for it is only found in five out of twenty
textbooks. Furthermore, Bentley's own implementation of binary search,
published in his 1986 book Programming Pearls, contains an error that remained
undetected for over twenty years.>

So to answer the question, you might use a module so that you
don't have to write, test, and debug your own implementation.


B<< Perl has C<grep>, hashes, and other alternatives, right? >>

Yes, before using this module the user should weigh the other options such as
linear searches ( C<grep> or C<List::Util::first> ), or hash based searches. A
binary search requires an ordered list, so one must weigh the cost of sorting or
maintaining the list in sorted order.  Ordered lists have O(n) time complexity
for inserts.  Binary Searches are best when the data set is already ordered, or
will be searched enough times to justify the cost of an initial sort.

There are cases where a binary search may be an excellent choice. Finding the
first matching element in a list of 1,000,000 items with a linear search would
have a worst-case of 1,000,000 iterations, whereas the worst case for a binary
search of 1,000,000 elements is about 20 iterations.  In fact, if many lookups
will be performed on a seldom-changed list, the savings of O(log n) lookups may
outweigh the cost of sorting or performing occasional linear time inserts.


=head1 EXPORT

Nothing is exported by default.  C<binsearch>, C<binsearch_pos>, and
C<binsearch_range> may be exported by listing them on the export list.

Or import all functions by specifying C<:all>.

=head1 SUBROUTINES/METHODS

=head2 WHICH SEARCH ROUTINE TO USE

=over 4

=item * C<binsearch>: Returns lowest index where match is found, or undef.

=item * C<binsearch_pos>: Returns lowest index where match is found, or the
index of the best insert point for needle if the needle isn't found.

=item * C<binsearch_range>: Performs a search for both low and high needles.
Returns a pair of indices refering to a range of elements corresponding to
low and high needles.

=back

=head2 binsearch CODE NEEDLE ARRAY_HAYSTACK

    $first_found_ix = binsearch { $a cmp $b } $needle, @haystack;

Pass a code block, a search target, and an array to search.  Uses
the supplied code block C<$needle> to test the needle against elements
in C<@haystack>.

See the section entitled B<The Callback Block>, below, for an explanation
of how the comparator works
(hint: very similar to C<< sort { $a <=> $b } ... >> ).

Return value will be the lowest index of an element that matches target, or
undef if target isn't found.

=head2 binsearch_pos CODE NEEDLE ARRAY_HAYSTACK

    $first_found_ix = binsearch_pos { $a cmp $b } $needle, @haystack;

The only difference between this function and C<binsearch> is its return
value upon failure.  C<binsearch> returns undef upon failure.
C<binsearch_pos> returns the index of a valid insert point for
C<$needle>.

Pass a code block, a search target, and an array to search.  Uses
the code block to test C<$needle> against elements in C<@haystack>.

Return value is the index of the first element equaling C<$needle>.  If no
element is found, the best insert-point for C<$needle> is returned.


=head2 binsearch_range CODE LOW_NEEDLE HIGH_NEEDLE ARRAY_HAYSTACK

    my( $low, $high )
      = binsearch_range { $a <=> $b }, $low_needle, $high_needle, @haystack;

Given C<$low_needle> and C<$high_needle>, returns a set of indices that
represent the range of elements fitting within C<$low_needle> and
C<$high_needle>'s bounds.  This might be useful, for example, in finding all
transations that occurred between 02012013 and 02292013.

I<This algorithm was adapted from Mastering Algorithms with Perl, page 172 and
173.>

=head2 The callback block (The comparator)

Comparators in L<List::BinarySearch> are used to compare the target (needle)
with individual haystack elements, returning the result of the relational
comparison of the two values.  A good example would be the code block in a
C<sort> function.

Basic comparators might be defined like this:

    # Numeric comparisons:
    binsearch { $a <=> $b } $needle, @haystack;

    # Stringwise comparisons:
    binsearch { $a cmp $b } $needle, @haystack;

    # Unicode Collation Algorithm comparisons
    $Collator = Unicode::Collate->new;
    binsearch { $Collator->( $a, $b ) } $needle, @haystack;

C<$a> represents the target.  C<$b> represents the contents of the haystack
element being tested.  This leads to an asymmetry that might be prone to
"gotchas" when writing custom comparators for searching complex data structures.
As an example, consider the following data structure:

    my @structure = (
        [ 100, 'ape'  ],
        [ 200, 'cat'  ],
        [ 300, 'dog'  ],
        [ 400, 'frog' ]
    );

A numeric custom comparator for such a data structure would look like this:

    sub{ $a <=> $b->[0] }

In this regard, the callback is unlike C<sort>, because C<sort> is always
comparing to elements, whereas C<binsearch> is comparing a target with an
element.

Just as with C<sort>, the comparator must return -1, 0, or 1 to signify "less
than", "equal to", or "greater than".

=head2 DEPRECATED FUNCTIONS

B<The following have been deprecated and should not be used.>  They will be
eliminated in a near-future version of L<List::BinarySearch>.  The companion
module, L<List::BinarySearch::XS> provides enough performance gain as to render
numeric-specialized and string-specialized versions of the binary search routine
obsolete.  If you need high performance, install List::BinarySearch::XS.

=head3 bsearch_custom

Replaced by binsearch. Same syntax.

=head3 bsearch_custom_pos

Replaced by binsearch_pos. Same syntax.

=head3 bsearch_custom_range

Replaced by binsearch_range. Same syntax.

=head3 bsearch_str

Instead use C<< binsearch { $a cmp $b } $needle, @haystack; >>.

=head3 bsearch_str_pos

Instead use C<< binsearch_pos { $a cmp $b } $needle, @haystack; >>.

=head3 bsearch_str_range

Instead use C<< binsearch_range { $a cmp $b } $needle, @haystack; >>.

=head3 bsearch_num

Instead use C<< binsearch { $a <=> $b } $needle, @haystack; >>.

=head3 bsearch_num_pos

Instead use C<< binsearch_pos { $a <=> $b } $needle, @haystack; >>.

=head3 bsearch_num_range

Instead use C<< binsearch_range { $a <=> $b } $needle, @haystack; >>.

=head3 bsearch_transform

Instead use C<< binsearch { $comparator->($a,$b) } $needle, @haystack; >>.

Also, the old "pass by @_" callbacks have been deprecated in favor of callbacks
that use C<$a> and C<$b>.  If you have been using:
C<< bsearch_custom {$_[0] <=>$_[1]} $needle, @haystack; >>, instead use:
C<< binsearch { $a <=> $b } $needle, @haystack; >>.  It's much easier on
the eyes.


=head1 DATA SET REQUIREMENTS

A well written general algorithm should place as few demands on its data as
practical.  The three requirements that these Binary Search algorithms impose
are:

=over 4

=item * B<The list must be in ascending sorted order>.

This is a big one.  The best sort routines run in O(n log n) time.  It makes no
sense to sort a list in O(n log n) time, and then perform a single O(log n)
binary search when List::Util C<first> could accomplish the same thing in O(n)
time without sorting.

=item * B<The list must be in ascending sorted order.>

A Binary Search consumes O(log n) time. We don't want to waste linear time
verifying the list is sordted, so B<there is no validity checking. You have
been warned.>

=item * B<These functions are prototyped> as (&$\@) or ($\@).

What this implementation detail means is that C<@haystack> is implicitly passed
by reference.  This is the price we pay for a familiar user interface, cleaner
calling syntax, and the automatic efficiency of pass-by-reference.

=item * B<Objects in the search lists must be capable of being evaluated for
relationaity.>

I threw that in for C++ folks who have spent some time with Effective STL.  For
everyone else don't worry; if you know how to C<sort> you know how to
C<binsearch>.

=back

=head1 UNICODE SUPPORT

Lists sorted according to the Unicode Collation Algorithm must be searched using
the same Unicode Collation Algorithm, Here's an example using
L<Unicode::Collate>'s C<< $Collator->cmp($a,$b) >>:

    my $found_index = binsearch { $Collator->cmp($a, $b) } $needle, @haystack;


=head1 CONFIGURATION AND ENVIRONMENT

By installing L<List::BinarySearch::XS>, the pure-Perl versions of C<binsearch>
and C<binsearch_pos> will be automatically replaced with XS versions for
markedly improved performance.  C<binsearch_range> also benefits from the XS
plug-in, since internally it makes calls to C<binsearch_pos>.

Users are strongly advised to install L<List::BinarySearch::XS>.  If, after
installing List::BinarySearch::XS, one wishes to disable the XS plugin, setting
C<$ENV{List_BinarySearch_PP}> to a true value will prevent the XS module from
being used by L<List::BinarySearch>.  This setting will have no effect on users
who use List::BinarySearch::XS directly.

For the sake of code portability, it's recommended to use List::BinarySearch as
the front-end, as it will automatically and portably downgrade to the pure-Perl
version if the XS module can't be loaded.


=head1 DEPENDENCIES

This module uses L<Exporter|Exporter>, and automatically makes use of
L<List::BinarySearch::XS> if it's installed on the user's system.

This module should support Perl versions 5.6 and newer in its pure-Perl form.
The optional XS extension can only be installed on Perl 5.8 or newer.


=head1 INCOMPATIBILITIES

The XS plugin for this module is not compatible with Perl 5.6.


=head1 DIAGNOSTICS


=head1 SEE ALSO

L<List::BinarySearch::XS>: An XS plugin for this module; install it, and this
module will use it automatically for a nice performance improvement.  May also
be used on its own.

=head1 AUTHOR

David Oswald, C<< <davido at cpan.org> >>

If the documentation fails to answer your question, or if you have a comment
or suggestion, send me an email.


=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-list-binarysearch at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=List-BinarySearch>.  I will be
notified, and then you'll automatically be notified of progress on your bug as I
make changes.



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

Thank-you to those who provided advice on user interface and XS
interoperability.

L<Mastering Algorithms with Perl|http://shop.oreilly.com/product/9781565923980.do>,
from L<O'Reilly|http://www.oreilly.com>: for the inspiration (and much of the
code) behind the positional and ranged searches.  Quoting MAwP: "I<...the
binary search was first documented in 1946 but the first algorithm that worked
for all sizes of array was not published until 1962.>" (A summary of a passage
from Knuth: Sorting and Searching, 6.2.1.)

I<Although the basic idea of binary search is comparatively straightforward,
the details can be surprisingly tricky...>  -- Donald Knuth


=head1 LICENSE AND COPYRIGHT

Copyright 2012 David Oswald.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
