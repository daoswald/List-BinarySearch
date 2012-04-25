#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Data::Dumper;

use List::BinarySearch qw( bsearch_array bsearch_list );


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
    plan tests => 10;
    for my $ix ( 0 .. $#integers ) {
        is(
            bsearch_array( \@integers, $integers[$ix] ),
            $ix,
            "bsearch_array: Integer ($integers[$ix]) found in position ($ix)."
        );
        is(
            bsearch_list( $integers[$ix], @integers ),
            $ix,
            "bsearch_list:  Integer ($integers[$ix]) found in position ($ix)."
        );
    }
    done_testing();
};

subtest "Even length list tests."   => sub {
    plan tests => 16;
    for my $ix ( 0 .. $#even_length ) {
        is(
            bsearch_array( \@even_length, $even_length[$ix] ),
            $ix,
            "bsearch_array: Even-list: ($even_length[$ix])" .
            " found at index ($ix)."
        );
        is(
            bsearch_list( $even_length[$ix], @even_length ),
            $ix,
            "bsearch_list:  Even-list: ($even_length[$ix])" .
            " found at index ($ix)."
        );
    }
    is(
        bsearch_array( \@even_length,700 ), undef,
        "bsearch_array: undef returned in scalar context if no numeric match."
    );
    is(
        bsearch_list( 700, @even_length ), undef,
        "bsearch_list:  undef returned in scalar context if no numeric match."
    );
    my @array = bsearch_array( \@even_length, 350 );
    is(
        scalar @array, 0,
        "bsearch_array: Empty list returned in list context " .
        "if no numeric match."
    );
    @array = bsearch_list( 350, @even_length );
    is(
        scalar @array, 0,
        "bsearch_list:  Empty list returned in list context " .
        "if no numeric match."
    );
    done_testing();
};


subtest "Non-unique key tests (stable search guarantee)."  => sub {
    plan tests => 3;
    is(
        bsearch_array( \@non_unique, 200 ),
        1, "bsearch_array: First occurrence of 200 found at 1."
    );
    is(
        bsearch_array( \@non_unique, 400 ),
        3, "bsearch_array: First occurrence of 400 found at 3 (odd index)."
    );
    is(
        bsearch_array( \@non_unique, 500 ),
        6, "bsearch_array: First occurrence of 500 found at 6 (even index)."
    );
    done_testing();
};

subtest "String default comparator tests."  => sub {
    plan tests => 12;
    for my $ix ( 0 .. $#strings ) {
        is(
            bsearch_array( \@strings, $strings[$ix] ),
            $ix,
            "bsearch_array: Strings: ($strings[$ix]) found at index ($ix)."
        );
        is(
            bsearch_list( $strings[$ix], @strings ),
            $ix,
            "bsearch_list:  Strings: ($strings[$ix]) found at index ($ix)."
        );
    }
    is(
        bsearch_array( \@strings, 'dave' ), undef,
        "bsearch_array: undef returned in scalar context for no string match."
    );
    is(
        bsearch_list( 'dave', @strings ), undef,
        "bsearch_list:  undef returned in scalar context for no string match."
    );
    done_testing();
};

subtest "Complex data structure testing with custom comparator." => sub {
    plan tests => 11;
    for my $ix ( 0 .. $#data_structs ) {
        is(
            bsearch_array(
                \@data_structs,
                $data_structs[$ix][0],
                sub{ $_[0] <=> $_[1][0] }
            ),
            $ix,
            "bsearch_array: Custom comparator test for test element $ix."
        );
        is(
            bsearch_list(
                sub{ $_[0] <=> $_[1][0] },
                $data_structs[$ix][0],
                @data_structs
            ),
            $ix,
            "bsearch_list:  Custom comparator test for test element $ix."
        );
    }
    is(
        bsearch_list( sub{ $_[0] <=> $_[1][0] }, 900, @data_structs ),
        undef,
        "bsearch_list:  undef returned for no match with custom comparator."
    );
    done_testing();
};

done_testing();
