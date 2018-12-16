#!/usr/bin/perl
use Data::Dumper;
use strict;
use Time::Piece;
use ExtUtils::Installed;
use Sys::Hostname;

my $hostname = hostname;
my $date = localtime->strftime('%Y-%m-%d');
my $path = "/tmp/";
my $file = "getDependencies-". $date .".log";
my $new_file = "errorDependencies_" . $hostname . "-". $date .".log";

unless(open FILE, '>'.$path.$new_file) {
    # Die with error message 
    # if we can't open it.
    die "\nUnable to create $file\n";
}

open(my $fh, '<:encoding(UTF-8)', $path . $file)
  or die "Could not open file '$file' $!";

my @dependecies;
while (my $row = <$fh>) {
  chomp $row;
  push( @dependecies, $row);
}

my $instmod = ExtUtils::Installed->new();
foreach my $dep (@dependecies) {
    # my $version = $instmod->version($module) || "???";
    # print "$module -- $version\n";

  if ( !($dep ~~ $instmod->modules()) ) {
     # Number of results for sudo cpan
    # 0: OK
    # 3328: Permission denied
    my $result = system("perldoc -l " . $dep . " 2>> " . $path . $new_file);
    if($result != 0){
      system( "sudo cpan " . $dep . " 2>> " . $path . $new_file);
    }
  }
}