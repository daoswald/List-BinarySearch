#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
    use_ok( 'List::BinarySearch', qw( :all ) )
        || BAIL_OUT();
}

diag( "Testing List::BinarySearch " .
      "$List::BinarySearch::VERSION, Perl $], $^X"
);


can_ok(
    'List::BinarySearch',
    qw(
        bsearch_str         bsearch_str_pos     bsearch_str_range
        bsearch_num         bsearch_num_pos     bsearch_num_range
        bsearch_custom      bsearch_custom_pos
        bsearch_transform
    )
);

done_testing();
