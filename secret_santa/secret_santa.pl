#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);

use List::Util qw(shuffle);

use Email::Valid;

use utf8::all;
use Encode qw(encode);

use MIME::Lite;

my ($verb, $file);

GetOptions(
    'v|verbose' => \$verb,
    'f|file=s'  => \$file,
) or die "Usage: $0 -f|--file FILENAME [-v|--verbose]";

defined $file or die "Usage: $0 -f|--file FILENAME";


open INFILE, "<", $file;

my @bag;
my %contacts;

while (<INFILE>) {
    chomp;

    /^ \w+ \s [\w\.]+@[\w\.]+ $/ix or die "Malformed file\n";

    my ($name, $email) = split / /;
    Email::Valid->address($email) or die "Malformed email address $email\n";

    $contacts{$name} = $email;
    push @bag, $name;
}


my %draw;

TRY: while () {
    foreach my $name (my @copy = @bag) {
        @bag = shuffle @bag;

        my $pick = shift @bag;
        if ($pick eq $name) {
            # last person picked themselves, try again
            if (@bag == 0) {
                @bag = @copy;
                next TRY;
            }
            push @bag, $pick;
            $pick = shift @bag;
        }
        $draw{$name} = $pick;
    }
    last TRY;
}

if ($verb) {
    foreach my $name (keys %draw) {
        my $pick = $draw{$name};
        print "$name\t$pick\n";
    }
}


foreach my $from (keys %draw) {

    my $to = $draw{$from};

    my $body = email_body($from, $to);

    if ($verb) {
        print "Emailed $contacts{$from} about their present for $to\n";
    }

    my $msg = MIME::Lite->new(
        From     => 'santa@northpole.com',
        To       => $contacts{$from},
        Subject  => 'Secret Santa',
        Data     => encode('UTF-8', $body),
        Type     => 'text/plain; charset=UTF-8',
        Encoding => '8bit',
    );

    $msg->send;
}

exit;

sub email_body {
    my ($from, $to) = @_;

    return <<EOF;
Greetings, $from!

For this year's Secret Santa, you will be buying for: $to

The guide price is £10. Gifts will be exchanged on Christmas Day.

Please contact Santa's Little Helpers with any queries.

Best wishes,

Santa
EOF
}



=head1 NAME

secret_santa

=head1 SYNOPSIS

./secret_santa -f|--file [-v|--verbose]

=head1 DESCRIPTION

Generates Secret Santa pairs and sends emails to people in the list

=head1 ARGUMENTS

=over

=item -v, --verbose

Print out the pairs to the console

=item -f, --file

The list of people to participate, name and email separated by a space, one per line

=back

=cut

