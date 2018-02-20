#!/usr/bin/perl

use warnings;
use strict;

use Cwd;
use Data::Dumper;
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);

my ($verb, $input, $root, @drives);

GetOptions(
    'v|verbose'  => \$verb,
    'i|input=s'  => \$input,
    'o|output=s' => \$root,
) or die "Usage: $0 -i|--input FILENAME [-o|--output PATH -v|--verbose]";


defined $input or die "Usage: $0 -i|--input FILENAME [-o|--output PATH -v|--verbose]";

$root ||= "root";

main ();

# we assume that all roots in the file are absolute, and all files belong partition
sub main {
	open (my $input_fh , "<" , $input) or die "Can't open $input:  $!";

	# use a nested hash to hold the directory structure
	my $tree = { };

	# split by slashes and add children to tree for each path
	while (<$input_fh>) {
		chomp;

		my $t = $tree;
		$t = $t->{$_} //= {} for split /\\/, $_;
	}

	close $input_fh;

    if ($verb) {
       # print Dumper $tree;
    }

    # begin recreating directory structure
    mkdir($root);
    chdir($root);
    create_dirs($tree);
}

# traverse tree and create directories, discarding files (leaves)
sub create_dirs {
    my $tree = shift;

    foreach (keys %$tree) {
        unless (/\./) {
            if ($verb) {
                print "Creating directory " . getcwd() . "\/$_\n";
            }
            mkdir($_);
            chdir($_);
            create_dirs($tree->{$_});
            chdir(getcwd() . "\/..");
        }
    }

}
