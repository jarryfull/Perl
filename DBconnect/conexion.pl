#!/usr/bin/perl
use strict;
use warnings;
use DBI;

my $driver = "mysql"; 
my $database = "DATABASE";
my $dsn = "DBI:$driver:database=$database";
my $userid = "USER";
my $password = "PASSWORD";

my $dbh = DBI->connect($dsn, $userid, $password ) or die $DBI::errstr;

# Test Query
my $sth = $dbh->prepare("SELECT * FROM USERS");
$sth->execute() or die $DBI::errstr;
print "Number of rows found: " . $sth->rows;
while (my @row = $sth->fetchrow_array()) {
   my ($id, $username, $name, $email ) = @row;
   print "\nID: $id,\nUsername: $username,\nName: $name,\nEmail: $email\n";
}
$sth->finish();