#!/usr/bin/perl
use Data::Dumper;
use strict;
use Time::Piece;
use ExtUtils::Installed;

# Get the Today date
my $date = localtime->strftime('%Y-%m-%d');
# Path where the file will be create
my $path = "/tmp/";
# Define the name of the .log
my $file = "getDependencies-". $date .".log";

# Get the installed Modules of Perl
my $instmod = ExtUtils::Installed->new();
# Use the open() function to create the file.
unless(open FILE, '>'.$path.$file) {
    # Die with error message 
    # if we can't open it.
    die "\nUnable to create $file\n";
}

foreach my $module ($instmod->modules()) {
    # Write in the file every Module that was finded
    print FILE $module . "\n";
}

# close the file.
close FILE;