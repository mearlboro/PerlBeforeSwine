#!/usr/bin/perl

use warnings;
use strict;

use Cwd;
use Data::Dumper;
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);
use File::Copy qw(move);

my ($verb, $list, $dir_in, $dir_out);

GetOptions(
    'v|verbose'         => \$verb,
    'l|list_of_files=s' => \$list,
    'f|files_dir=s'     => \$dir_in,
    'd|dest_dir=s'      => \$dir_out,
) or die "Usage: $0 -l|--list_of_files -f|--files_dir -d|--dest_dir [-v|--verbose]";


defined $list or die "Usage: $0 -l|--list_of_files -f|--files_dir -d|--dest_dir [-v|--verbose]";

$dir_in  ||= "files";
$dir_out ||= "root";

main ();

sub main {
	open (my $input_fh , "<" , $list) or die "Can't open file $list:  $!\n";

    # save file path in hash of lists
	my %hash = ();

	# split by slashes, grab filename, save path in list of values
	while (<$input_fh>) {
		chomp;

	    push @{ $hash{$1} }, $_ if (/\\([^.\\]+\.[^.\\]+)$/);
    }

	close $input_fh;

    if ($verb) {
       print Dumper %hash;
    }

    # check files in $root_in, if they are in hash, put them in the right subfolder of $root_out
    opendir my $dir_in_h, $dir_in;
    my @files = readdir $dir_in_h or die "Can't enter directory $dir_in: $!\n";
    closedir $dir_in_h;

    foreach my $f (@files) {
      if ($hash{$f} and scalar @{$hash{$f}} == 1) {
        my $path = "$dir_out\\$hash{$f}[0]";
        # linux forward slashes
        $path =~ s/\\/\//g;

        if ($verb) {
            print "Moving $f to new location $path\n";
        }
        move("$dir_in//$f", $path) or die "Cannot move $f to $path: $!\n";
      }
    }

}

