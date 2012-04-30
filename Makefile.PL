use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'List::BinarySearch',
    AUTHOR              => q{David Oswald <davido@cpan.org>},
    VERSION_FROM        => 'lib/List/BinarySearch.pm',
    ABSTRACT_FROM       => 'lib/List/BinarySearch.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    BUILD_REQUIRES		=> {
		'Test::More' => '0.98',
	},
    PREREQ_PM => {
        'Scalar::Util' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'List-BinarySearch-*' },
);
