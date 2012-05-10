## no critic (RCS,VERSION)

use strict;
use warnings;

use ExtUtils::MakeMaker;

## no critic (may require interpolation)
WriteMakefile(
    NAME               => 'List::BinarySearch',
    AUTHOR             => q{David Oswald <davido [@at] cpan [d.o.t] org>},
    VERSION_FROM       => 'lib/List/BinarySearch.pm',
    ABSTRACT_FROM      => 'lib/List/BinarySearch.pm',
    LICENSE            => 'perl',
    MIN_PERL_VERSION   => '5.006000',
    PL_FILES           => {},
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '6.62',    # Core, but updated version.
    },
    BUILD_REQUIRES => {
        'Test::More' => '0.98',             # Core, but updated version.
        'English'    => '0',                # Core.
    },
    PREREQ_PM => {
        'Scalar::Util' => '0',              # Core: Being explicit.
    },
    META_MERGE => {
        provides => {
            'List::BinarySearch' => {
                file    => 'lib/List/BinarySearch.pm',
                version => '0.08'
            },
        },
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'List-BinarySearch-*' },
);
