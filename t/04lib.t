
use Test::More tests => 4;

use IO::File;

my $good_file = File::Spec->catfile(qw(t lib lib-good.pl));
my $bad_file = File::Spec->catfile(qw(t lib lib-bad.pl));
my $good_no_file = File::Spec->catfile(qw(t lib lib-no-good.pl));
my $bad_no_file = File::Spec->catfile(qw(t lib lib-no-bad.pl));

$good_file = IO::File->new(">$good_file") or die "cannot open lib-good.pl: $!";
$bad_file = IO::File->new(">$bad_file") or die "cannot open lib-bad.pl: $!";
$good_no_file = IO::File->new(">$good_no_file") or die "cannot open lib-no-good.pl: $!";
$bad_no_file = IO::File->new(">$bad_no_file") or die "cannot open lib-no-bad.pl: $!";

require CGI;

my $good_test = $CGI::VERSION; 
my $bad_test = $good_test + 1;
my $good_no_test = $CGI::VERSION + 1; 
my $bad_no_test = $CGI::VERSION;

print $good_file <<EOF;
use Acme::No;
use CGI $good_test;
1;
EOF

print $bad_file <<EOF;
use Acme::No;
use CGI $bad_test;
1;
EOF

print $good_no_file <<EOF;
use Acme::No;
no CGI $good_no_test;
use CGI $good_test;
my \$q = CGI->new or die;
die unless UNIVERSAL::isa(\$q, 'CGI');
1;
EOF

print $bad_no_file <<EOF;
use Acme::No;
no CGI $bad_no_test;
1;
EOF

undef $good_file;
undef $bad_file;
undef $good_no_file;
undef $bad_no_file;

my $rc = do 't/lib/lib-good.pl';
ok($rc, "use an ok version of an external library");

$rc = do 't/lib/lib-bad.pl';
ok(!$rc, "use a version of a library that's too high");

$rc = do 't/lib/lib-no-good.pl';
ok($rc, "no an ok version of an external library");

$rc = do 't/lib/lib-no-bad.pl';
ok(!$rc, "no a version of a library that's too low");

