
use Test::More tests => 7;

use IO::File;
use File::Spec;
use Config;

my $good_file = File::Spec->catfile(qw(t lib perl-good.pl));
my $bad_file = File::Spec->catfile(qw(t lib perl-bad.pl));
my $good_no_file = File::Spec->catfile(qw(t lib perl-no-good.pl));
my $bad_no_file = File::Spec->catfile(qw(t lib perl-no-bad.pl));
my $bad_no_file2 = File::Spec->catfile(qw(t lib perl-no-bad2.pl));
my $string_bad_file = File::Spec->catfile(qw(t lib perl-string-bad.pl));
my $string_good_file = File::Spec->catfile(qw(t lib perl-string-good.pl));

$good_file = IO::File->new(">$good_file") or die "cannot open perl-good.pl: $!";
$bad_file = IO::File->new(">$bad_file") or die "cannot open perl-bad.pl: $!";
$good_no_file = IO::File->new(">$good_no_file") or die "cannot open perl-no-good.pl: $!";
$bad_no_file = IO::File->new(">$bad_no_file") or die "cannot open perl-no-bad.pl: $!";
$bad_no_file2 = IO::File->new(">$bad_no_file2") or die "cannot open perl-no-bad2.pl: $!";
$string_bad_file = IO::File->new(">$string_bad_file") or die "cannot open perl-string-bad.pl: $!";
$string_good_file = IO::File->new(">$string_good_file") or die "cannot open perl-string-good.pl: $!";

my $good_perl = $];
my $bad_perl = $] + 1;
my $good_no_perl = $] + 1;
my $bad_no_perl = $];

my $rev = $Config{PERL_REVISION};
my $ver = $Config{PERL_VERSION};
my $subver = $Config{PERL_SUBVERSION};

print $good_file <<EOF;
use Acme::No;
use $good_perl;
1;
EOF

print $bad_file <<EOF;
use Acme::No;
use $bad_perl;
1;
EOF

print $good_no_file <<EOF;
use Acme::No;
no $good_no_perl;
1;
EOF

print $bad_no_file <<EOF;
use Acme::No;
no $bad_no_perl;
1;
EOF

print $bad_no_file2 <<EOF;
use Acme::No;
no $rev.$ver.$subver;
1;
EOF

print $string_bad_file <<EOF;
use Acme::No;
no v$bad_no_perl;
1;
EOF

print $string_good_file <<EOF;
use Acme::No;
no v$good_no_perl;
1;
EOF

undef $good_file;
undef $bad_file;
undef $good_no_file;
undef $bad_no_file;
undef $string_good_file;
undef $string_bad_file;

my $rc = do 't/lib/perl-good.pl';
ok($rc, "use an ok version of perl");

$rc = do 't/lib/perl-bad.pl';
ok(!$rc, "use a version of perl that's too high");

$rc = do 't/lib/perl-no-good.pl';
ok($rc, "no an ok version of perl");

$rc = do 't/lib/perl-no-bad.pl';
ok(!$rc, "no a version of perl that's too high");

$rc = do 't/lib/perl-no-bad2.pl';
ok(!$rc, "no a version of perl that's too high");

$rc = do 't/lib/perl-string-good.pl';
ok($rc, "no an ok version of perl in form v5.6.1");

$rc = do 't/lib/perl-string-bad.pl';
ok(!$rc, "no a version of perl that's too high in form v5.6.1");
