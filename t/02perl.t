
use Test::More tests => 10;

use IO::File;
use File::Spec;
use Config;

use strict;

my @filenames;
my @filehandles;

push @filenames, File::Spec->catfile(qw(t lib perl-good.pl));
push @filenames, File::Spec->catfile(qw(t lib perl-bad.pl));
push @filenames, File::Spec->catfile(qw(t lib perl-no-good.pl));
push @filenames, File::Spec->catfile(qw(t lib perl-no-bad.pl));
push @filenames, File::Spec->catfile(qw(t lib perl-no-bad2.pl));
push @filenames, File::Spec->catfile(qw(t lib perl-no-bad3.pl));
push @filenames, File::Spec->catfile(qw(t lib perl-no-bad4.pl));
push @filenames, File::Spec->catfile(qw(t lib perl-no-bad5.pl));
push @filenames, File::Spec->catfile(qw(t lib perl-string-bad.pl));
push @filenames, File::Spec->catfile(qw(t lib perl-string-good.pl));

foreach my $file (@filenames) {
  push @filehandles, IO::File->new(">$file") or die "cannot open file: $!";
}

my $good_perl = $];
my $bad_perl = $] + 1;
my $good_no_perl = $] + 1;
my $bad_no_perl = $];

my $rev = $Config{PERL_REVISION};
my $ver = $Config{PERL_VERSION};
my $subver = $Config{PERL_SUBVERSION};

my $fh = $filehandles[0];
print $fh <<EOF;
use Acme::No;
use $good_perl;
1;
EOF

$fh = $filehandles[1];
print $fh <<EOF;
use Acme::No;
use $bad_perl;
1;
EOF

$fh = $filehandles[2];
print $fh <<EOF;
use Acme::No;
no $good_no_perl;
1;
EOF

$fh = $filehandles[3];
print $fh <<EOF;
use Acme::No;
no $bad_no_perl;
1;
EOF

$fh = $filehandles[4];
print $fh <<EOF;
use Acme::No;
no $rev.$ver.$subver;
1;
EOF

$fh = $filehandles[5];
print $fh <<EOF;
use Acme::No;
no $rev.$ver;
1;
EOF

$fh = $filehandles[6];
print $fh <<EOF;
use Acme::No;
no 5.00503;
1;
EOF

$fh = $filehandles[7];
print $fh <<EOF;
use Acme::No;
no 5.005_03;
1;
EOF

$fh = $filehandles[8];
print $fh <<EOF;
use Acme::No;
no v$bad_no_perl;
1;
EOF

$fh = $filehandles[9];
print $fh <<EOF;
use Acme::No;
no v$good_no_perl;
1;
EOF

foreach my $filehandle (@filehandles) {
  $filehandle->close;
}

my $rc = do $filenames[0];
ok($rc, "use $good_perl ($filenames[0])");

$rc = do $filenames[1];
ok(!$rc, "use $bad_perl ($filenames[1])");

$rc = do $filenames[2];
ok($rc, "no $good_no_perl ($filenames[2])");

$rc = do $filenames[3];
ok(!$rc, "no $bad_no_perl ($filenames[3])");

$rc = do $filenames[4];
ok(!$rc, "no $rev.$ver.$subver ($filenames[4])");

$rc = do $filenames[5];
ok(!$rc, "no $rev.$ver ($filenames[5])");

$rc = do $filenames[6];
ok(!$rc, "no 5.00503 ($filenames[6])");

$rc = do $filenames[7];
ok(!$rc, "no 5.005_03 ($filenames[7])");

$rc = do $filenames[8];
ok(!$rc, "no v$bad_no_perl ($filenames[8])");

$rc = do $filenames[9];
ok($rc, "no v$good_no_perl ($filenames[9])");
