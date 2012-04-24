#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

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
    plan tests => scalar( @integers ) * 2;
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
    plan tests => scalar( @even_length ) * 2;
    for my $ix ( 0 .. $#even_length ) {
        is(
            bsearch_array( \@even_length, $even_length[$ix] ),
            $ix,
            "bsearch_array: Even-list: ($even_length[$ix]) found at index ($ix)."
        );
        is(
            bsearch_list( $even_length[$ix], @even_length ),
            $ix,
            "bsearch_list:  Even-list: ($even_length[$ix]) found at index ($ix)."
        );
    }
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
    plan tests => 10;
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
    done_testing();
};
done_testing();
