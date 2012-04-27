#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Data::Dumper;

use List::BinarySearch qw( bsearch_arrayref bsearch_list bsearch_transform_arrayref );


my @integers     =   ( 100, 200, 300,  400, 500      );
my @even_length  =   ( 100, 200, 300,  400, 500, 600 );
my @non_unique   =   ( 100, 200, 200,  400, 400, 400, 500, 500 );
my @strings      = qw( ape  bat  bear  cat  dog      );
my @data_structs =   (
    [ 100, 'ape'  ],
    [ 200, 'bat'  ],
    [ 300, 'bear' ],
    [ 400, 'cat'  ],
    [ 500, 'dog'  ],
);

subtest "Numeric comparator tests (odd-length list)."     => sub {
    plan tests => 15;
    for my $ix ( 0 .. $#integers ) {
        is(
            bsearch_arrayref( \@integers, $integers[$ix] ),
            $ix,
            "bsearch_arrayref:           Integer ($integers[$ix]) " .
            "found in position ($ix)."
        );
        is(
            bsearch_list( $integers[$ix], @integers ),
            $ix,
            "bsearch_list:               Integer ($integers[$ix]) " .
            "found in position ($ix)."
        );
        is(
            bsearch_transform_arrayref( \@integers, $integers[$ix], sub{ $_[0] } ),
            $ix,
            "bsearch_transform_arrayref: Integer ($integers[$ix]) " .
            "found in position ($ix)."
        );
    }
    done_testing();
};

subtest "Even length list tests."   => sub {
    plan tests => 24;
    for my $ix ( 0 .. $#even_length ) {
        is(
            bsearch_arrayref( \@even_length, $even_length[$ix] ),
            $ix,
            "bsearch_arrayref:           Even-list: ($even_length[$ix])" .
            " found at index ($ix)."
        );
        is(
            bsearch_list( $even_length[$ix], @even_length ),
            $ix,
            "bsearch_list:               Even-list: ($even_length[$ix])" .
            " found at index ($ix)."
        );
        is(
            bsearch_transform_arrayref( \@even_length, $even_length[$ix], sub{ $_[0] } ),
            $ix,
            "bsearch_transform_arrayref: Even-list: ($even_length[$ix])" .
            " found at index ($ix)."
        );
    }
    is(
        bsearch_arrayref( \@even_length, 700 ), undef,
        "bsearch_arrayref:           undef returned in scalar " .
        "context if no numeric match."
    );
    is(
        bsearch_list( 700, @even_length ), undef,
        "bsearch_list:               undef returned in scalar context if no numeric match."
    );
    is(
        bsearch_transform_arrayref( \@even_length, 700 ), undef,
        "bsearch_transform_arrayref: undef returned in scalar " .
        "context if no numeric match."
    );
    my @array = bsearch_arrayref( \@even_length, 350 );
    is(
        scalar @array, 0,
        "bsearch_arrayref:           Empty list returned in list context " .
        "if no numeric match."
    );
    @array = bsearch_list( 350, @even_length );
    is(
        scalar @array, 0,
        "bsearch_list:               Empty list returned in list context " .
        "if no numeric match."
    );
    @array = bsearch_transform_arrayref( \@even_length, 350 );
    is(
        scalar( @array ), 0,
        "bsearch_transform_arrayref: Empty list returned in list contect " .
        "if no numberic match."
    );
    done_testing();
};


subtest "Non-unique key tests (stable search guarantee)."  => sub {
    plan tests => 9;
    is(
        bsearch_arrayref( \@non_unique, 200 ), 1,
        "bsearch_arrayref:           First non-unique key of 200 found at 1."
    );
    is(
        bsearch_list( 200, @non_unique ), 1,
        "bsearch_list:               First non-unique key of 200 found at 1."
    );
    is(
        bsearch_transform_arrayref( \@non_unique, 200 ), 1,
        "bsearch_transform_arrayref: First non-unique key of 200 found at 1."
    );
    is(
        bsearch_arrayref( \@non_unique, 400 ), 3,
        "bsearch_arrayref:           First occurrence of 400 found at 3 " .
        "(odd index)."
    );
    is(
        bsearch_list( 400, @non_unique ), 3,
        "bsearch_list:               First occurrence of 400 found at 3 " .
        " (odd index)."
    );
    is(
        bsearch_transform_arrayref( \@non_unique, 400, sub{ $_[0] } ), 3,
        "bsearch_transform_arrayref: First occurrence of 400 found at 3 " .
        " (odd index)."
    );

    is(
        bsearch_arrayref( \@non_unique, 500 ), 6,
        "bsearch_arrayref:           First occurrence of 500 found at 6 " .
        "(even index)."
    );
    is(
        bsearch_list( 500, @non_unique ), 6,
        "bsearch_list:               First occurrence of 500 found at 6 " .
        "(even index)."
    );
    is(
        bsearch_transform_arrayref( \@non_unique, 500 ), 6,
        "bsearch_transform_arrayref: First occurrence of 500 found at 6 " .
        "(even index)."
    );

    done_testing();
};

subtest "String default comparator tests."  => sub {
    plan tests => 18;
    for my $ix ( 0 .. $#strings ) {
        is(
            bsearch_arrayref( \@strings, $strings[$ix] ),
            $ix,
            "bsearch_arrayref:           " .
            "Strings: ($strings[$ix]) found at index ($ix)."
        );
        is(
            bsearch_list( $strings[$ix], @strings ),
            $ix,
            "bsearch_list:               " .
            "Strings: ($strings[$ix]) found at index ($ix)."
        );
        is(
            bsearch_transform_arrayref( \@strings, $strings[$ix] ),
            $ix,
            "bsearch_transform_arrayref: " .
            "Strings: ($strings[$ix]) found at index ($ix)."
        );
    }
    is(
        bsearch_arrayref( \@strings, 'dave' ), undef,
        "bsearch_arrayref:           undef returned in scalar " .
        "context for no string match."
    );
    is(
        bsearch_list( 'dave', @strings ), undef,
        "bsearch_list:               undef returned in scalar " .
        "context for no string match."
    );
    is(
        bsearch_transform_arrayref( \@strings, 'dave' ), undef,
        "bsearch_transform_arrayref: undef returned in scalar " .
        "context for no string match."
    );
    done_testing();
};

subtest "Complex data structure testing with custom comparator." => sub {
    plan tests => 18;
    for my $ix ( 0 .. $#data_structs ) {
        is(
            bsearch_arrayref(
                \@data_structs,
                $data_structs[$ix][0],
                sub{ $_[0] <=> $_[1][0] }
            ),
            $ix,
            "bsearch_arrayref:           Custom comparator test for test " .
            " element $ix."
        );
        is(
            bsearch_list(
                sub{ $_[0] <=> $_[1][0] },
                $data_structs[$ix][0],
                @data_structs
            ),
            $ix,
            "bsearch_list:               Custom comparator test for test " .
            "element $ix."
        );
        is(
            bsearch_transform_arrayref(
                \@data_structs,
                $data_structs[$ix][0],
                sub{ $_[0][0] }
            ),
            $ix,
            "bsearch_transform_arrayref: Custom transformer test for test " .
            "element $ix."
        );
    }
    is(
        bsearch_arrayref( \@data_structs, 900, sub{ $_[0] <=> $_[1][0] } ),
        undef,
        "bsearch_arrayref:           undef returned for no match with " .
        "custom comparator."
    );
    is(
        bsearch_list( sub{ $_[0] <=> $_[1][0] }, 900, @data_structs ),
        undef,
        "bsearch_list:               undef returned for no match with " .
        "custom comparator."
    );
    is(
        bsearch_transform_arrayref( \@data_structs, 900, sub{ $_[0][0] } ),
        undef,
        "bsearch_transform_arrayref: undef returned for no match with " .
        "custom transformer."
    );
    done_testing();
};


done_testing();
