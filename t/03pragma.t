
use Test::More tests => 4;

use IO::File;

use strict;

my @filenames;
my @filehandles;

push @filenames, File::Spec->catfile(qw(t lib pragma-good.pl));
push @filenames, File::Spec->catfile(qw(t lib pragma-bad.pl));
push @filenames, File::Spec->catfile(qw(t lib pragma-working.pl));
push @filenames, File::Spec->catfile(qw(t lib pragma-no.pl));

foreach my $file (@filenames) {
  push @filehandles, IO::File->new(">$file") or die "cannot open file: $!";
}

my $fh = $filehandles[0];
print $fh <<EOF;
use Acme::No;
use strict;
1;
EOF

$fh = $filehandles[1];
print $fh <<EOF;
use Acme::No;
use blarg;
1;
EOF

$fh = $filehandles[2];
print $fh <<EOF;
use Acme::No;
use strict;
\$foo = 1;   # this should error under strict;
1;
EOF

$fh = $filehandles[3];
print $fh <<EOF;
use Acme::No;
use strict;
my \$foo = 1;

no strict qw(vars);
\$bar = 1;   # this should be ok
1;
EOF

foreach my $filehandle (@filehandles) {
  $filehandle->close;
}

my $rc = do $filenames[0];
ok($rc, "use strict ($filenames[0])");

$rc = do $filenames[1];
ok(!$rc, "use blarg ($filenames[1])");

$rc = do $filenames[2];
ok(!$rc, "make sure 'use strict' works ($filenames[2])");

$rc = do $filenames[3];
ok($rc, "make sure 'no strict qw(vars)' works ($filenames[3])");

