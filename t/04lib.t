
use Test::More tests => 4;

use IO::File;
require CGI;

use strict;

my @filenames;
my @filehandles;

push @filenames, File::Spec->catfile(qw(t lib lib-good.pl));
push @filenames, File::Spec->catfile(qw(t lib lib-bad.pl));
push @filenames, File::Spec->catfile(qw(t lib lib-no-good.pl));
push @filenames, File::Spec->catfile(qw(t lib lib-no-bad.pl));

foreach my $file (@filenames) {
  push @filehandles, IO::File->new(">$file") or die "cannot open file: $!";
}

my $good_test = $CGI::VERSION; 
my $bad_test = $good_test + 1;
my $good_no_test = $CGI::VERSION + 1; 
my $bad_no_test = $CGI::VERSION;

my $fh = $filehandles[0];
print $fh <<EOF;
use CGI $good_test;
1;
EOF

$fh = $filehandles[1];
print $fh <<EOF;
use Acme::No;
use CGI $bad_test;
1;
EOF

$fh = $filehandles[2];
print $fh <<EOF;
use Acme::No;
no CGI $good_no_test;
use CGI $good_test;
my \$q = CGI->new or die;
die unless UNIVERSAL::isa(\$q, 'CGI');
1;
EOF

$fh = $filehandles[3];
print $fh <<EOF;
use Acme::No;
no CGI $bad_no_test;
1;
EOF

foreach my $filehandle (@filehandles) {
  $filehandle->close;
}

my $rc = do $filenames[0];
ok($rc, "use CGI $good_test ($filenames[0])");

$rc = do $filenames[1];
ok(!$rc, "use CGI $bad_test ($filenames[1]");

$rc = do $filenames[2];
ok($rc, "no CGI $good_no_test ($filenames[2]");

$rc = do $filenames[3];
ok(!$rc, "no CGI $bad_no_test ($filenames[3]");

