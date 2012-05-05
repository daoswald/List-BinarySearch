#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use List::BinarySearch qw( :all );

my @integers    = ( 100, 200, 300, 400, 500 );
my @even_length = ( 100, 200, 300, 400, 500, 600 );
my @non_unique  = ( 100, 200, 200, 400, 400, 400, 500, 500 );
my @strings      = qw( ape  bat  bear  cat  dog      );
my @data_structs = (
    [ 100, 'ape' ],
    [ 200, 'bat' ],
    [ 300, 'bear' ],
    [ 400, 'cat' ],
    [ 500, 'dog' ],
);

subtest "Numeric comparator tests (odd-length list)." => sub {
    plan tests => 15;
    for my $ix ( 0 .. $#integers ) {
        is( bsearch_num( $integers[$ix], @integers ),
            $ix,
            "bsearch_num:                Integer ($integers[$ix]) "
                . "found in position ($ix)."
        );
        is( bsearch_custom(
                sub { $_[0] <=> $_[1] },
                $integers[$ix], @integers
            ),
            $ix,
            "bsearch_custom:           Integer ($integers[$ix]) "
                . "found in position ($ix)."
        );
        is( bsearch_transform( sub { $_[0] }, $integers[$ix], @integers ),
            $ix,
            "bsearch_transform: Integer ($integers[$ix]) "
                . "found in position ($ix)."
        );
    }
    done_testing();
};

subtest "Even length list tests." => sub {
    plan tests => 16;
    for my $ix ( 0 .. $#even_length ) {
        is( bsearch_custom(
                sub { $_[0] <=> $_[1] },
                $even_length[$ix], @even_length
            ),
            $ix,
            "bsearch_custom:           Even-list: ($even_length[$ix])"
                . " found at index ($ix)."
        );
        is( bsearch_transform(
                sub { $_[0] },
                $even_length[$ix], @even_length
            ),
            $ix,
            "bsearch_transform: Even-list: ($even_length[$ix])"
                . " found at index ($ix)."
        );
    }
    is( bsearch_custom( sub { $_[0] <=> $_[1] }, 700, @even_length ),
        undef,
        "bsearch_custom:           undef returned in scalar "
            . "context if no numeric match."
    );
    is( bsearch_transform( sub { $_[0] }, 700, @even_length ),
        undef,
        "bsearch_transform: undef returned in scalar "
            . "context if no numeric match."
    );
    my @array = bsearch_custom( sub { $_[0] <=> $_[1] }, 350, @even_length );
    is( scalar @array,
        0,
        "bsearch_custom:           Empty list returned in list context "
            . "if no numeric match."
    );
    @array = bsearch_transform( sub { $_[0] }, 350, @even_length );
    is( scalar(@array), 0,
              "bsearch_transform: Empty list returned in list contect "
            . "if no numberic match." );
    done_testing();
};

subtest "Non-unique key tests (stable search guarantee)." => sub {
    plan tests => 6;
    is( bsearch_custom( sub { $_[0] <=> $_[1] }, 200, @non_unique ),
        1,
        "bsearch_custom:           First non-unique key of 200 found at 1." );
    is( bsearch_transform( sub { $_[0] }, 200, @non_unique ),
        1, "bsearch_transform: First non-unique key of 200 found at 1." );
    is( bsearch_custom( sub { $_[0] <=> $_[1] }, 400, @non_unique ),
        3,
        "bsearch_custom:           First occurrence of 400 found at 3 "
            . "(odd index)."
    );
    is( bsearch_transform( sub { $_[0] }, 400, @non_unique ),
        3,
        "bsearch_transform: First occurrence of 400 found at 3 "
            . " (odd index)."
    );

    is( bsearch_custom( sub { $_[0] <=> $_[1] }, 500, @non_unique ),
        6,
        "bsearch_custom:           First occurrence of 500 found at 6 "
            . "(even index)."
    );
    is( bsearch_transform( sub { $_[0] }, 500, @non_unique ),
        6,
        "bsearch_transform: First occurrence of 500 found at 6 "
            . "(even index)."
    );

    done_testing();
};

subtest "String default comparator tests." => sub {
    plan tests => 18;
    for my $ix ( 0 .. $#strings ) {
        is( bsearch_str( $strings[$ix], @strings ),
            $ix,
            "bsearch:                    "
                . "Strings: ($strings[$ix]) found at index ($ix)."
        );
        is( bsearch_custom(
                sub { $_[0] cmp $_[1] }, $strings[$ix], @strings
            ),
            $ix,
            "bsearch_custom:           "
                . "Strings: ($strings[$ix]) found at index ($ix)."
        );
        is( bsearch_transform( sub { $_[0] }, $strings[$ix], @strings ),
            $ix,
            "bsearch_transform: "
                . "Strings: ($strings[$ix]) found at index ($ix)."
        );
    }
    is( bsearch_str( 'dave', @strings ),
        undef,
        "bsearch:                    undef returned in scalar "
            . "context for no string match."
    );
    is( bsearch_custom( sub { $_[0] cmp $_[1] }, 'dave', @strings ),
        undef,
        "bsearch_custom:           undef returned in scalar "
            . "context for no string match."
    );
    is( bsearch_transform( sub { $_[0] }, 'dave', @strings ),
        undef,
        "bsearch_transform: undef returned in scalar "
            . "context for no string match."
    );
    done_testing();
};

subtest "Complex data structure testing with custom comparator." => sub {
    plan tests => 12;
    for my $ix ( 0 .. $#data_structs ) {
        is( bsearch_custom(
                sub { $_[0] <=> $_[1][0] }, $data_structs[$ix][0],
                @data_structs
            ),
            $ix,
            "bsearch_custom:           Custom comparator test for test "
                . " element $ix."
        );
        is( bsearch_transform(
                sub { $_[0][0] },
                $data_structs[$ix][0],
                @data_structs
            ),
            $ix,
            "bsearch_transform: Custom transformer test for test "
                . "element $ix."
        );
    }
    is( bsearch_custom( sub { $_[0] <=> $_[1][0] }, 900, @data_structs ),
        undef,
        "bsearch_custom:           undef returned for no match with "
            . "custom comparator."
    );
    is( bsearch_transform( sub { $_[0][0] }, 900, @data_structs ),
        undef,
        "bsearch_transform: undef returned for no match with "
            . "custom transformer."
    );
    done_testing();
};

done_testing();
