
use Test::More tests => 4;

use IO::File;

my $good_file = File::Spec->catfile(qw(t lib pragma-good.pl));
my $bad_file = File::Spec->catfile(qw(t lib pragma-bad.pl));
my $working_file = File::Spec->catfile(qw(t lib pragma-working.pl));
my $no_file = File::Spec->catfile(qw(t lib pragma-no.pl));

$good_file = IO::File->new(">$good_file") or die "cannot open pragma-good.pl: $!";
$bad_file = IO::File->new(">$bad_file") or die "cannot open pragma-bad.pl: $!";
$working_file = IO::File->new(">$working_file") or die "cannot open pragma-working.pl: $!";
$no_file = IO::File->new(">$no_file") or die "cannot open pragma-no.pl: $!";


print $good_file <<EOF;
use Acme::No;
use strict;
1;
EOF

print $bad_file <<EOF;
use Acme::No;
use blarg;
1;
EOF

print $working_file <<EOF;
use Acme::No;
use strict;
\$foo = 1;   # this should error under strict;
1;
EOF

print $no_file <<EOF;
use Acme::No;
use strict;
my \$foo = 1;

no strict 'vars';
\$bar = 1;   # this should be ok
1;
EOF

undef $good_file;
undef $bad_file;
undef $working_file;
undef $no_file;

my $rc = do 't/lib/pragma-good.pl';
ok($rc, "use an ok pragma");

$rc = do 't/lib/pragma-bad.pl';
ok(!$rc, "use bad pragma");

$rc = do 't/lib/pragma-working.pl';
ok(!$rc, "make sure 'use pragma' works");

$rc = do 't/lib/pragma-no.pl';
ok($rc, "make sure 'no pragma' works");

