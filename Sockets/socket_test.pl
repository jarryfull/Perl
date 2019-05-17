#!/usr/bin/perl
################################################################################
#   Created by: Jaime Ochoa (jaime.ochoa.valdivia@gmail.com)
#   Created On: 16/05/2019
#
#   Description: 
#   The purpose of this script is to open a socket to request something from a server with the method GET and print the response
################################################################################

use strict;
use warnings;
use IO::Socket::INET;
use Data::Dumper;

my $server = 'localhost'; # You can add here an IP or a Hostname 
my $port = 3000; # Which port is listening?
my $protocol = 'tcp'; # Which protocol will be used?

# Creating an object to request something to the socket
my $socket = IO::Socket::INET->new(
    Proto => $protocol,
    PeerAddr => $server,
    PeerPort => $port
) || die "[!] Can not connect...!!!\n";

# Which URL will be requested
my $url = '/';

print "Connecting to \n Server: $server \n Port: $port \n URL: $url \n";

my $request = "GET $url HTTP/1.1\n\n"; # This "$socket "GET $url HTTP/1.0\n\n" to the target, The \n\n are needed in the HTTP GET Headers
$socket->send($request);

$socket->recv(my $data, 1024); # This gets the data recived and puts it in $data
print "$data \n"; # Then print the data
close($socket); # And finally close the Socket