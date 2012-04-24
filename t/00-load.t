#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'List::BinarySearch' ) || print "Bail out!\n";
}

diag( "Testing List::BinarySearch $List::BinarySearch::VERSION, Perl $], $^X" );
