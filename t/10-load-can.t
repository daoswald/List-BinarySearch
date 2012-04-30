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
        bsearch_str         bsearch_num
        bsearch_custom      bsearch_general
        bsearch_transform
    )
);

done_testing();
