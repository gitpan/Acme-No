use 5.006;

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Acme::No',
    'VERSION_FROM'	=> 'No.pm',
    'PREREQ_PM'		=> {Test::More => 0,
                            Filter::Util::Call => 0,
                            File::Spec => 0,
                            IO::File => 0,
                            Carp => 0},
    clean        	=> { FILES => 't/lib/pragma*.pl t/lib/perl*.pl t/lib/lib*.pl' },
);
