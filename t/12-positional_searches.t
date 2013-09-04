#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

BEGIN {
  # Force pure-Perl testing.
  $ENV{List_BinarySearch_PP} = 1; ## no critic (local)
}

use List::BinarySearch qw( :all );

my @integers    = ( 100, 200, 300, 400, 500 );
my @strings      = qw( ape  bat  bear  cat  dog );

subtest
    "Test numeric search function that returns insert position upon no-match."
    => sub {
        plan tests => 8;
        is(
            bsearch_num_pos( 100, @integers ), 0,
            "bsearch_num_pos:    Found at position 0."
        );
        is(
            binsearch_pos( sub{ $a <=> $b }, 100, @integers ), 0,
            "bsearch_custom_pos: Found at position 0."
        );
        is(
            bsearch_num_pos( 50, @integers ), 0,
            "bsearch_num_pos: Insert at position 0."
        );
        is(
            bsearch_num_pos( 300, @integers ), 2,
            "bsearch_num_pos: Found at position 2."
        );
        is(
            bsearch_num_pos( 350, @integers ), 3,
            "bsearch_num_pos: Insert at position 3."
        );
        is(
            bsearch_num_pos( 500, @integers ), 4,
            "bsearch_num_pos: Found at last position."
        );
        is( binsearch_pos( sub{ $a <=> $b }, 500, @integers ), 4,
            "bsearch_custom_pos: Found at last position."
        );
        is(
            bsearch_num_pos( 550, @integers ), 5,
            "bsearch_num_pos: Insert after last position."
        );
        done_testing();
};

# my @strings      = qw( ape  bat  bear  cat  dog );

subtest
    "Test string search function that returns insert position upon no-match."
    => sub {
        plan tests => 7;
        is(
            bsearch_str_pos( 'ape', @strings ), 0,
            "bsearch_str_pos: Found at position 0."
        );
        is(
            bsearch_str_pos( 'ant', @strings ), 0,
            "bsearch_str_pos: Insert at position 0."
        );
        is(
            bsearch_str_pos( 'bear', @strings ), 2,
            "bsearch_str_pos: Found at position 2."
        );
        is(
            bsearch_str_pos( 'bafoon', @strings ), 1,
            "bsearch_str_pos: Insert at position 1."
        );
        is(
            bsearch_str_pos( 'dog', @strings ), 4,
            "bsearch_str_pos: Found at last position."
        );
        is(
            bsearch_str_pos( 'zebra', @strings ), 5,
            "bsearch_str_pos: Insert after last position."
        );
        is(
            binsearch_pos( sub{ $a cmp $b }, 'zebra', @strings ),
            5, "bsearch_custom_pos: Insert after last position."
        );
        done_testing();
};

subtest "Test range functions." => sub {
    plan tests => 8;
    my( $low, $high );
    ( $low, $high ) = bsearch_str_range( 'ape', 'bear', @strings );
    is( $low,  0, "bsearch_str_range: Found low  at 0." );
    is( $high, 2, "bsearch_str_range: Found high at 2." );

    ( $low, $high ) = bsearch_str_range( 'bear', 'zebra', @strings );
    is( $low,  2, "bsearch_str_range: Found low  at 2." );
    is( $high, 4, "bsearch_str_range: Includes high of 4 (not found)." );

    ( $low, $high ) = bsearch_num_range( 100, 300, @integers );
    is( $low,  0, "bsearch_num_range: Numeric low."  );
    is( $high, 2, "bsearch_num_range: Numeric high." );
    ( $low, $high )
      = ( binsearch_range { $a cmp $b }  'bat', 'cat', @strings );
  is( $low,  1, "bsearch_custom_range: Found low at 1." );
  is( $high, 3, "bsearch_custom_range: Found high at 3." );
  
    done_testing();
};

done_testing();
