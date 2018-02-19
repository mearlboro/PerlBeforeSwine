#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);


my ($verb, $input, $output, @drives);

GetOptions(
    'v|verbose'  => \$verb,
    'i|input=s'  => \$input,
    'o|output=s' => \$output,
	'd|drive=s'  => \@drives,
) or die "Usage: $0 -i|--input FILENAME -d|--drive [-o|--output FILENAME -v|--verbose]";


defined $input or die "Usage: $0 -i|--input FILENAME -d|--drive [-o|--output FILENAME -v|--verbose]";

$output ||= "files.out";

main ();


sub main {

	open (my $input_fh , "<" , $input ) or die "Can't open $input:  $!";
	open (my $output_fh, ">>", $output) or die "Can't open $output: $!";

	while (<$input_fh>) {
		chomp;

		my $path = process_line($_);

		if ($path) {
			print $output_fh "$path\n";
		}
	}

	close $input_fh;
	close $output_fh;
}

sub process_line {
	my $line = shift;

	foreach my $drive (@drives) {
		if ($line =~ /$drive:\\/) {

			return strip_line($line);
		}
	}
}

sub strip_line {
	my $line = shift;

	if ($line =~ m/<([^>]+)>        # opening tag
                        ([^<]+)     # capture path
                    <\/\1>          # closing tag
                  /x) {

		return $2;
	}
	else {
		if ($verb) {
			print "Malformed line: $line\n";
		}
	}
}
