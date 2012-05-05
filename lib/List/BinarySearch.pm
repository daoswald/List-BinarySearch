## no critic (RCS)

package List::BinarySearch;

use strict;
use warnings;

use Scalar::Util qw( looks_like_number );

require Exporter;

# Perl::Critic advises to 'use base'.  The documentation for 'base' suggests
# using 'parent'.  'parent' would exclude older Perls.  So we'll avoid the
# issue by just using @ISA, as advised in the Exporter POD.

our @ISA       = qw(Exporter);    ## no critic (ISA)
our @EXPORT_OK = qw(
  bsearch_str       bsearch_str_pos     bsearch_str_range
  bsearch_num       bsearch_num_pos     bsearch_num_range
  bsearch_custom    bsearch_custom_pos
  bsearch_transform
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

# I debated whether or not to use prototypes, decided that List::Util and
# List::MoreUtils set the interface standard for these sorts of functions.
# It seemed best to use a familiar interface.

## no critic (prototypes)

our $VERSION = '0.07';

# Needed for developer's releases: See perlmodstyle.
# $VERSION = eval $VERSION;    ## no critic (eval,version)


# There is a lot of repetition in the code.  This is an intentional means of
# favoring a small amount of computational efficiency over concise code by
# avoiding unnecessary function call overhead.


# Search using stringwise comparisons.  Return an index on success, undef or
# an empty list (depending on context) upon failure.

sub bsearch_str ($\@) {
    my ( $target, $aref ) = @_;
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


# Search using numeric comparisons.

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



# Use a callback for comparisons.

sub bsearch_custom (&$\@) {
    my ( $code, $target, $aref ) = @_;
    my $min = 0;
    my $max = $#{$aref};
    while ( $max > $min ) {
        my $mid = int( ( $min + $max ) / 2 );
        if ( $code->( $target, $aref->[$mid] ) > 0 ) {
            $min = $mid + 1;
        }
        else {
            $max = $mid;
        }
    }

    return $min
      if $max == $min && $code->( $target, $aref->[$min] ) == 0;

    return;    # Undef in scalar context, empty list in list context.
}


# Use a callback to transform the list elements before comparing.  Comparisons
# will be stringwise or numeric depending on what target looks like.

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



# Virtually identical to bsearch_str, but upon match-failure returns best
# insert position for $target.

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


# Identical to bsearch_num, but upon match-failure returns best insert
# position for $target.

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


# Identical to bsearch_custom, but upon match-failure returns best insert
# position for $target.

sub bsearch_custom_pos (&$\@) {
    my ( $comp, $target, $aref ) = @_;
    my ( $low,    $high ) = ( 0, scalar @{$aref} );
    while ( $low < $high ) {
        my $cur = int( ( $low + $high ) / 2 );
        if( $comp->( $target, $aref->[$cur] ) > 0 ) {
            $low = $cur + 1;
        }
        else {
            $high = $cur;
        }
    }
    return $low;
}


# Given a low and a high target, returns a range of indices representing
# where low and high fit into @haystack.

sub bsearch_str_range ($$\@) {
    my ( $low_target, $high_target, $aref ) = @_;
    my $index_low  = bsearch_str_pos( $low_target,  @{$aref} );
    my $index_high = bsearch_str_pos( $high_target, @{$aref} );
    if (   $index_high == @{$aref}
        or $aref->[$index_high] gt $high_target )
    {
        $index_high--;
    }
    return ( $index_low, $index_high );
}



sub bsearch_num_range ($$\@) {
    my ( $low_target, $high_target, $aref ) = @_;
    my $index_low  = bsearch_num_pos( $low_target,  @{$aref} );
    my $index_high = bsearch_num_pos( $high_target, @{$aref} );
    if (   $index_high == @{$aref}
        or $aref->[$index_high] > $high_target )
    {
        $index_high--;
    }
    return ( $index_low, $index_high );
}


1;    # End of List::BinarySearch

__END__

=head1 NAME

List::BinarySearch - Binary Search a sorted list or array.

=head1 VERSION

Version 0.07

New function: bsearch_custom_pos.


=head1 SYNOPSIS

This module performs a binary search on an array passed by reference, or on
an array or list passed as a flat list.

Examples:


    use List::BinarySearch qw( :all );
    use List::BinarySearch qw(
        bsearch_str         bsearch_str_pos         bsearch_str_range
        bsearch_num         bsearch_num_pos         bsearch_num_range
        bsearch_custom
        bsearch_transform
    );


    my @num_array =   ( 100, 200, 300, 400, 500 );
    my $index;


    # Find the first index of element containing the number 300.
    
    $index = bsearch_num       300, @num_array;
    $index = bsearch_custom    { $_[0] <=> $_[1] } 300, @num_array;
    $index = bsearch_transform { $_[0]           } 300, @num_array;


    my @str_array = qw( Bach Beethoven Brahms Mozart Schubert );

    # Find the first index of element containing the string 'Mozart'.

    $index = bsearch_str       'Mozart', @str_array;
    $index = bsearch_custom    { $_[0] cmp $_[1] } 'Mozart', @str_array;
    $index = bsearch_transform { $_[0]           } 'Mozart', @str_array;


    # All functions return 'undef' if nothing is found:

    $index = bsearch_str 'Meatloaf', @str_array;    # not found: returns undef
    $index = bsearch_num 42,         @num_array;    # not found: returns undef


    # Complex data structures:

    my @complex = (
        [ 'one',   1 ],
        [ 'two',   2 ],
        [ 'three', 3 ],
        [ 'four' , 4 ],
        [ 'five' , 5 ],
    );


    # Find 'one' from the structure above:

    $index = bsearch_custom    { $_[0] cmp $_[1][0] } 'one', @complex;
    $index = besarch_transform { $_[1][0]           } 'one', @complex;


    # The following functions return an optimal insert point if no match.

    my @str_array = qw( Bach Beethoven Brahms Mozart Schubert );
    my @num_array =   ( 100, 200, 300, 400 );

    $index = bsearch_str_pos 'Chopin', @str_array; # Returns 3 - Best insert-at position.
    $index = bsearch_num_pos 500, @num_array; # Returns 4 - Best insert-at position.


    # The following functions return an inclusive range.

    my( $low_ix, $high_ix )
        = bsearch_str_range( 'Beethoven', 'Mozart', @str_array );
        # Returns ( 1, 3 ), meaning ( 1 .. 3 ).

    my( $low_ix, $high_ix )
        = bsearch_num_range( 200, 400, @num_array );



=head1 DESCRIPTION

A binary search searches B<sorted> lists using a divide and conquer technique.
On each iteration the search domain is cut in half, until the result is found.
The computational complexity of a binary search is O(log n).

The binary search algorithm implemented in this module is known as a
Deferred Detection variant on the traditional Binary Search.  Deferred
Detection provides B<stable searches>.  Stable binary search algorithms have
the following characteristics, contrasted with their unstable binary search
cousins:

=over 4

=item * In the case of non-unique keys, a stable binary search will
always return the lowest-indexed matching element.  An unstable binary search
would return the first one found, which may not be the chronological first.

=item * Best and worst case time complexity is always O(log n).  Unstable
searches may find the target in fewer iterations in the best case, but in the
worst case would still be O(log n).

=item * Stable binary searches only require one relational comparison of a
given pair of data elements per iteration, where unstable binary searches
require two comparisons per iteration.

=item * The net result is that although an unstable binary search might have
a better "best case" time complexity, the fact that a stable binary search
gets away with fewer comparisons per iteration gives it better performance
in the worst case, and approximately equal performance in the average case.
By trading away slightly better "best case" performance, the stable search
gains the guarantee that the element found will always be the lowest-indexed
element in a range of non-unique keys.

=back

=head1 RATIONALE

Quoting from
L<Wikipedia|http://en.wikipedia.org/wiki/Binary_search_algorithm>:  I<When Jon
Bentley assigned it as a problem in a course for professional
programmers, he found that an astounding ninety percent failed to code a
binary search correctly after several hours of working on it, and another
study shows that accurate code for it is only found in five out of twenty
textbooks. Furthermore, Bentley's own implementation of binary search,
published in his 1986 book Programming Pearls, contains an error that remained
undetected for over twenty years.>

So the answer to the question "Why use a module for this?" is "So that you
don't have to write, test, and debug your own implementation."

Nevertheless, before using this module the user should weigh the other
options: linear searches ( C<grep> or C<List::Util::first> ), or hash based
searches. A binary search only makes sense if the data set is already sorted
in ascending order, and if it is determined that the cost of a linear search,
or the linear-time conversion to a hash-based container is too inefficient or
demands too much memory.  So often, it just doesn't make sense to try to
optimize beyond what Perl's tools natively provide.

However, there are cases where, a binary search may be an excellent choice.
Finding the first matching element in a list of 1,000,000 items with a linear
search would have a worst-case of 1,000,000 iterations, whereas the worst case
for a binary search of 1,000,000 elements is about 20 iterations.  In fact, if
many lookups will be performed on a seldom-changed list, the savings of
O(log n) lookups may outweigh the cost of sorting or performing occasional
ordered inserts.

Profile, then benchmark, then consider (and benchmark) the options, and
finally, optimize.



=head1 EXPORT

Nothing is exported by default.  Upon request will export C<bsearch_str>,
C<bsearch_num>, C<bsearch_custom>, C<bsearch_transform>,
C<bsearch_num_pos>, C<bsearch_str_pos>, C<bsearch_custom_pos>,
C<bsearch_str_range>, and C<bsearch_num_range>.  Or import all functions
by specifying C<:all>.



=head1 SUBROUTINES/METHODS

=head2 WHICH SEARCH ROUTINE TO USE

A binary search is supposed to be fast and efficient.  And it's such a good
algorithm that in profiling this module it was observed that excessive logic
paths and internal subroutine calls lead quickly to consuming more cycles
than the algorithm itself for just about any data set that will fit into
memory.  In the interest of keeping user interfaces as simple as possible, as
well as limiting the overhead of complex decision paths and internal
subroutine calls, this module presents a number of similar functions with
subtle differences between them.  Here's a quick reference to which to choose:

=over 4

=item * C<bsearch_str>: Stringwise comparisons. Returns index or undef.

=item * C<bsearch_str_pos>: Stringwise comparisons.  Returns index or index
of insert point for needle.

=item * C<bsearch_num>: Numeric comparisons.  Returns index or undef.

=item * C<bsearch_num_pos>: Numeric comparisons.  Returns index or index of
insert point for needle.

=item * C<bsearch_custom>: Comparisons provided by user-defined callback.
Returns index or undef.

=item * C<bsearch_custom_pos>: Comparisons provided by user-defined callback.
Returns index or index of insert point for needle.

=item * C<bsearch_transform>: Transformations of list elements provided by
user-defined callback.  Returns index or undef.

=item * C<bsearch_str_range>: Stringwise comparisons for low and high needles.
Returns a pair of indices refering to a range of elements corresponding to
low and high needles.

=item * C<bsearch_num_range>: Numeric comparisons for low and high needles.
Returns a pair of indices referring to a range of elements corresponding to
low and high needles.

=back


=head2 SUBROUTINE CATEGORIES

There are three categories of subroutines.  Those that return undef (or an
empty list in list context) upon failure to find a match; Those that return
the best insert point for C<$needle> upon failure to find a match; And those
that return a range of elements spanning from C<$low_needle> to
C<$high_needle>.

There are also several comparison styles, for use with different sorts of
data.  The 'str' functions do stringwise comparisons.  The 'num' functions do
numeric comparisons.

The 'custom' function uses a callback for the comparison.  The 'transform'
function uses a callback to transform each list element in some user-defined
way before doing comparisons that are either numeric or string depending on
whether C<$needle> looks like a number or not.

With that explanation, here are the functions:


=head2 bsearch_str STRING_NEEDLE ARRAY_HAYSTACK

    $first_found_ix = bsearch_str $needle, @haystack;

Finds the string specified by C<$needle> in the array C<@haystack>.  Return
value is an index to the first (lowest numbered) matching element in
C<@haystack>, or C<undef> if nothing is found.  String comparisons are used.
The target must be an exact and complete match.



=head2 bsearch_num NUMERIC_NEEDLE ARRAY_HAYSTACK

    $first_found_ix = bsearch_num $needle, @haystack;

Finds the numeric needle C<$needle> in the haystack C<@haystack>.
Return value is an index to the first (lowest numbered) matching element
in C<@haystack>, or C<undef> if C<$needle> isn't found.

The comparison type is numeric.



=head2 bsearch_custom CODE NEEDLE ARRAY_HAYSTACK

    $first_found_ix = bsearch_custom { $_[0] cmp $_[1] } $needle, @haystack;
    $first_found_ix = bsearch_custom \&comparator,       $needle, @haystack;

Pass a code block or subref, a search target, and an array to search.  Uses
the subroutine supplied in the code block or subref callback to test
C<$needle> against elements in C<@haystack>.

Return value is the index of the first element equaling C<$needle>.  If no
element is found, undef is returned.

Beware a potential 'I<gotcha>': When dealing with complex data structures, the
callback function will have an asymmetrical look to it, which is easy to
get wrong.  The target will always be referred to by C<$_[0]>, but the right
hand side of the comparison must refer to the C<$_[1]...>, where C<...> is
the portion of the data structure to be used in the comparison: C<$_[1][$n]>,
or C<$_[1]{$k}>, for example.



=head2 bsearch_transform CODE NEEDLE ARRAY_HAYSTACK

    $first_found_ix = bsearch_transform { $_[0] }    $needle, @haystack;
    $first_found_ix = bsearch_transform \&transform, $needle, @haystack );

Pass a transform code block or subref, a needle to find, and a haystack to
find it in.  Return value is the lowest numbered index to an element matching
C<$needle>, or C<undef> if nothing is found.

This algorithm detects whether C<$needle> looks like a number or a string.  If
it looks like a number, numeric comparisons are performed.  Otherwise,
stringwise comparisons are used.  The transform code block or coderef is
used to transform each element of the search array to a value that can be
compared against the target.  This is useful if C<@haystack> contains a
complex data structure, and less prone to user error in such cases than
C<bsearch_custom>.

If no transformation is needed, use C<bsearch_str>, C<bsearch_num>, or
C<bsearch_custom>.



=head2 bsearch_str_pos STRING_NEEDLE ARRAY_HAYSTACK

    $first_found_ix = bsearch_str_pos $needle, @haystack;

The only difference between this function and C<bsearch_str> is its return
value upon failure.  C<bsearch_str> returns undef upon failure.
C<bsearch_str_pos> returns the index of a valid insert point for C<$needle>.

Finds the string specified by C<$needle> in the array C<@haystack>.  Return
value is an index to the first (lowest numbered) matching element in
C<@haystack>.  If C<$needle> isn't found, return value is the index of where
C<$needle> could appropriately be inserted.  String comparisons are used.
The target must be an exact and complete match.

The position returned upon failure to find C<$needle> satisfies these
requirements:  If C<$needle> is greater than all elements in C<@haystack>,
then the return value will be equal to C<scalar @haystack>.  If C<$needle> is
within the range represented by C<@haystack>, the return value will be the
index of the first element greater in value than C<$needle>.  In either case,
the following code could then be used to add C<$needle> to C<@haystack> if it
isn't found:

    my $index = bsearch_str_pos $needle, @haystack;
    if( $needle ne $haystack[$index] ) {
        splice @haystack, $index, 0, $needle;
    }



=head2 bsearch_num_pos NUMERIC_NEEDLE ARRAY_HAYSTACK

    $first_found_ix = bsearch_num_pos $needle, @haystack;

The only difference between this function and C<bsearch_num> is its return
value upon failure.  C<bsearch_num> returns undef upon failure.
C<bsearch_num_pos> returns the index of a valid insert point for C<$needle>.

Finds the string specified by C<$needle> in the array C<@haystack>.  Return
value is an index to the first (lowest numbered) matching element in
C<@haystack>.  If C<$needle> isn't found, return value is the index of where
C<$needle> could appropriately be inserted.  String comparisons are used.
The target must be an exact and complete match.

The position returned upon failure to find C<$needle> satisfies these
requirements:  If C<$needle> is greater than all elements in C<@haystack>,
then the return value will be equal to C<scalar @haystack>.  If C<$needle> is
less than, or within the range represented by C<@haystack>, the return value
will be the index of the first element greater in value than C<$needle>.  In
either case, the following code could then be used to add C<$needle> to
C<@haystack> if it isn't found:

    my $index = bsearch_num_pos $needle, @haystack;
    if( $needle != $haystack[$index] ) {
        splice @haystack, $index, 0, $needle;
    }


=head2 bsearch_custom_pos CODE NEEDLE ARRAY_HAYSTACK

    $first_found_ix = bsearch_custom_pos { $_[0] cmp $_[1] } $needle, @haystack;
    $first_found_ix = bsearch_custom_pos \&comparator,       $needle, @haystack;

The only difference between this function and C<bsearch_custom> is its return
value upon failure.  C<bsearch_custom> returns undef upon failure.
C<bsearch_custom_pos> returns the index of a valid insert point for
C<$needle>.

Pass a code block or subref, a search target, and an array to search.  Uses
the subroutine supplied in the code block or subref callback to test
C<$needle> against elements in C<@haystack>.

Return value is the index of the first element equaling C<$needle>.  If no
element is found, the best insert-point for C<$needle> is returned.

Beware a potential 'I<gotcha>': When dealing with complex data structures, the
callback function will have an asymmetrical look to it, which is easy to
get wrong.  The target will always be referred to by C<$_[0]>, but the right
hand side of the comparison must refer to the C<$_[1]...>, where C<...> is
the portion of the data structure to be used in the comparison: C<$_[1][$n]>,
or C<$_[1]{$k}>, for example.



=head2 bsearch_str_range LOW_STRING_NEEDLE HIGH_STRING_NEEDLE ARRAY_HAYSTACK

=head2 bsearch_num_range LOW_NUMERIC_NEEDLE HIGH_NUMERIC_NEEDLE ARRAY_HAYSTACK

Given C<$needle_low> and C<$needle_high>, return a low and high set of indices
that represent the range of elements fitting within C<$needle_low> and
C<$needle_high> (inclusive).

Here's an example:

    my @haystack = ( 100, 200, 300, 400, 500 );
    my( $low, $high ) = bsearch_num_range 200, 400, @haystack;
    my @found = @haystack[ $low .. $high ]; # @found holds ( 200, 300, 400 ).



=head2 \&comparator

B<(callback)>

Comparator functions are used by C<bsearch_custom>.

Comparators are references to functions that accept as parameters a target,
and a list element, returning the result of the relational comparison of the
two values.  A good example would be the code block in a C<sort> function,
except that our comparators get their input from C<@_>, where C<sort>'s
comparator functions get their input from C<$a> and C<$b>.

Basic comparators might be defined like this:

    # Numeric comparisons:
    $comp = sub {
        my( $needle, $haystack_item ) = @_;
        return $needle <=> $haystack_item;
    };

    # Non-numeric (stringwise) comparisons:
    $comp = sub {
        my( $needle, $haystack_item ) = @_;
        return $needle cmp $haystack_item;
    };

The first parameter passed to the comparator will be the target.  The second
parameter will be the contents of the element being tested.  This leads to
an asymmetry that might be prone to "gotchas" when writing custom comparators
for searching complex data structures.  As an example, consider the following
data structure:

    my @structure = (
        [ 100, 'ape'  ],
        [ 200, 'cat'  ],
        [ 300, 'dog'  ],
        [ 400, 'frog' ]
    );

A numeric custom comparator for such a data structure would look like this:

    sub{ $_[0] <=> $_[1][0]; }

...or more explicitly...

    sub{
        my( $needle, $haystack_item ) = @_;
        return $needle <=> $haystack_item->[0];
    }

Therefore, a call to C<bsearch_custom> where the target (or needle) is to
solve for C<$found_ix> such that C<$structure[$found_ix][0] == 200> might look
like this:

    my $found_ix = bsearch_custom { $_[0] <=> $_[1][0] }, 200, @structure;
    print $structure[$found_ix][1], "\n" if defined $found_ix;
    # prints 'cat'



=head2 \&transform

B<(callback)>

The transform callback routine is used by C<bsearch_transform()>
to transform a given search list element into something that can be compared
against C<$needle>.  As an example, consider the following complex data
structure:

    my @structure = (
        [ 100, 'ape'  ],
        [ 200, 'cat'  ],
        [ 300, 'dog'  ],
        [ 400, 'frog' ]
    );

If the goal is do a numeric search using the first element of each
integer/string pair, the transform sub might be written like this:

    sub transform {
        return $_[0][0];    # Returns 100, 200, 300, etc.
    }

Or if the goal is instead to search by the second element of each
int/str pair, the sub would instead look like this:

    sub transform {
        return $_[0][1];
    }

A transform sub that performs no transform would be a simple identity
function:

    sub transform { $_[0] }



=head1 DATA SET REQUIREMENTS

A well written general algorithm should place as few demands on its data as
practical.  The three requirements that these Binary Search algorithms impose
are:

=over 4

=item * B<The lists must be in ascending sorted order>.

This is a big one.  Keep in mind that the best sort routines run in
O(n log n) time.  It makes no sense to sort a list in O(n log n), and
then perform a single O(log n) binary search when List::Util C<first>
could accomplish the same thing in O(n) time.  A Binary Search only
makes sense if there are other good reasons for keeping the data set
sorted in the first place.

B<Passing an unsorted list to these Binary Search algorithms will result
in undefined behavior.  There is no validity checking.>

A Binary Search consumes O(log n) time.  It would, therefore, be foolish
for these algorithms to pre-check the list for sortedness, as that would
require linear, or O(n) time.  Since no sortedness testing is done,
there can be no guarantees as to what will happen if an unsorted list is
passed to a binary search.

=item * Data that is more complex than simple numeric or string lists
will require a custom comparator or transform subroutine.  This includes
search keys that are buried within data structures.

=item * These functions are prototyped, either as (&$\@), or as ($\@).
What this implementation detail means is that C<@haystack> is implicitly
and invisibly passed by reference.  Thus, bare lists will not work.
This downside of prototypes is an unfortunate side effect of specifying
an API thatclosely matches the one commonly used with List::Util and
List::MoreUtils functions.  It can contribute to surprise when the user
tries to pass a bare list.  The upside is a more familiar user
interface, and the efficiency of pass-by-ref.

=back



=head1 CONFIGURATION AND ENVIRONMENT

This module should run under any Perl from 5.6.0 onward.  There are no special
environment or configuration concerns to address.  In the future, an XS plugin
will be implemented, and at that time there may be additional configuration
details in this section.



=head1 DEPENDENCIES

This module uses L<Exporter|Exporter> and L<Scalar::Util|Scalar::Util>, both
of which are core modules.  Installation requires L<Test::More|Test::More>,
which is also a core module.



=head1 INCOMPATIBILITIES

This module hasn't been tested on Perl versions that predate Perl 5.6.0.



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

Thank-you to L<Max Maischein|http://search.cpan.org/~corion/> (Corion) for
being a willing and helpful sounding board on API issues, and for spotting
some POD problems.

L<Mastering Algorithms with Perl|http://shop.oreilly.com/product/9781565923980.do>,
from L<O'Reilly|http://www.oreilly.com>: for the inspiration (and much of the
code) behind the positional and ranged searches.  Quoting MAwP: "I<...the
binary search was first documented in 1946 but the first algorithm that worked
for all sizes of array was not published until 1962.>" (A summary of a passage
from Knuth: Sorting and Searching, 6.2.1.)

I<Necessity, who is the mother of invention.> -- plato.

I<Although the basic idea of binary search is comparatively straightforward,
the details can be surprisingly tricky...>  -- Donald Knuth



=head1 LICENSE AND COPYRIGHT

Copyright 2012 David Oswald.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
