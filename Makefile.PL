## no critic (RCS,VERSION)

use strict;
use warnings;

use ExtUtils::MakeMaker;
use Getopt::Std;

## no critic (may require interpolation eval)

use constant DIST_VERSION => '0.25';

my $prereq_pm = { 'Scalar::Util' => '0' };

my %opt;
getopts( 'ny', \%opt )
    and not ( $opt{y} && $opt{n} )
    or die <<EOD;
The only legal options are:
  -y = install List::BinarySearch::XS if not present,
  -n = do not install List::BinarySearch::XS.
You may not assert both of these at once - it is too confusing.
EOD

if( ! eval 'use List::BinarySearch::XS; 1;' ) {
  my $answer = 'n';
  unless( $ENV{LBS_NO_XS} ) {
    $answer = $opt{y} ? 'y' : $opt{n} ? 'n' :
      prompt <<'EOP' . 'Would you like to install List::BinarySearch::XS?', 'y';

List::BinarySearch::XS is not installed.

This module will provide a performance improvement.  Though it is not required
for proper operation, it is strongly recommended that this module be installed
unless the target environment is unable to compile XS modules.

Answering 'yes' to the following question will cause most CPAN installers to
pull in the List::BinarySearch::XS module automatically.  If you are doing a
manual installation you will probably need to install List::BinarySearch::XS
separately.

EOP
  }
  if( $answer =~ m/^y/i ) {
    $prereq_pm->{'List::BinarySearch::XS'} = '0'; # Add List::BinarySearch::XS
                                                  # to our list of dependencies.
    print "List::BinarySearch::XS has been added to the dependency list.\n";
  }
  else {
    print "List::BinarySearch::XS will not be added to the dependency list.\n";
  }
}
else {
  print "List::BinarySearch::XS has been detected. It will be used automatically.\n";
}


WriteMakefile(
    NAME               => 'List::BinarySearch',
    AUTHOR             => q{David Oswald <davido [@at] cpan [d.o.t] org>},
    VERSION_FROM       => 'lib/List/BinarySearch.pm',
    ABSTRACT_FROM      => 'lib/List/BinarySearch.pm',
    LICENSE            => 'perl',
    MIN_PERL_VERSION   => '5.008000',
    PL_FILES           => {},
    CONFIGURE_REQUIRES => {
	'Getopt::Std'         => 0,
        'ExtUtils::MakeMaker' => '6.62',    # Core, but updated version.
    },
    BUILD_REQUIRES => {
        'Test::More' => '0.98',             # Core, but updated version.
        'English'    => '0',                # Core.
    },
    PREREQ_PM => $prereq_pm,
    META_MERGE => {
        'meta-spec'   => { version => 2 },
        resources     => {
            bugtracker => {
                web => 'https://github.com/daoswald/List-BinarySearch/issues',
            },
            repository => {
                type  => 'git',
                url   => 'https://github.com/daoswald/List-BinarySearch.git',
                web   => 'https://github.com/daoswald/List-BinarySearch',
            },
        },
        provides      => {
            'List::BinarySearch' => {
                file    => 'lib/List/BinarySearch.pm',
                version => DIST_VERSION,
            },
            'List::BinarySearch::PP' => {
                file    => 'lib/List/BinarySearch/PP.pm',
                version => DIST_VERSION,
            },
        },
        prereqs => {
            runtime => {
                recommends    => {
                    'List::BinarySearch::XS' => '0.06',
                },
            },
        },
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'List-BinarySearch-*' },
);
