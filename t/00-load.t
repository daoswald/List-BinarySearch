#!/usr/bin/env perl

use Test::More tests => 2;

BEGIN {
    use_ok( 'Scalar::Util' ) || BAIL_OUT();
    use_ok( 'List::BinarySearch' ) || BAIL_OUT();
}

diag( "Testing List::BinarySearch " .
      "$List::BinarySearch::VERSION, Perl $], $^X"
);
