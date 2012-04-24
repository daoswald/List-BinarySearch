#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
    use_ok( 'List::BinarySearch', qw( bsearch_array bsearch_list ) )
        || BAIL_OUT();
}

diag( "Testing List::BinarySearch " .
      "$List::BinarySearch::VERSION, Perl $], $^X"
);


can_ok( 'List::BinarySearch', qw( bsearch_array bsearch_list ) );

done_testing();
