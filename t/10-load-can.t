#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
  # Force pure-Perl testing.
  $ENV{List_BinarySearch_PP} = 1; ## no critic (local)
}

BEGIN {
    use_ok( 'List::BinarySearch', qw( :all ) )
        || BAIL_OUT();
}


can_ok(
    'List::BinarySearch',
    qw(
        bsearch_str         bsearch_str_pos     bsearch_str_range
        bsearch_num         bsearch_num_pos     bsearch_num_range
        bsearch_custom      bsearch_custom_pos  bsearch_custom_range
        bsearch_transform
    )
);

done_testing();
