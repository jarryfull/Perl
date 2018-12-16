#!/usr/bin/env perl -I/stgsec/web/modules
##################################################################################
### (C) COPYRIGHT IBM Corp. 2017
##################################################################################
##  Description:  Tickets Report
##
##       Author:  Jaime Ochoa , jaimeale@mx1.ibm.com
##      VERSION:  1.0
##      Created:  05/31/2018 10:47 AM
##     Revision:  ---
##################################################################################

use MIME::Lite;
use Time::localtime;
use DBI;
use STG::DB;
use Time::Piece;
use Data::Dumper;
use Time::ParseDate qw(parsedate);

use warnings;
use strict;

my $itHelp = "https://stgithelp.rchland.ibm.com/ithelp/index.php?verb=view&defect=";

my $from   = 'stgsec@us.ibm.com';
my $subjet = 'Tickets Report';
#my $to     = 'jaimeale@mx1.ibm.com';
my $to     = 'cgeorge@us.ibm.com, ashj@us.ibm.com, ejmorin@us.ibm.com, sumantrana@sg.ibm.com, gizzac@us.ibm.com, diegoto@mx1.ibm.com, jaimeale@mx1.ibm.com, jorgemb@mx1.ibm.com, penaloza@mx1.ibm.com, quintero@mx1.ibm.com, rosanarm@mx1.ibm.com, valcaraz@mx1.ibm.com';
my $cc     = '';
my $bcc    = '';
my $html   = '';

my $server_db = $ENV{DBSERVER} ? $ENV{DBSERVER} : "secdb1.raleigh.ibm.com";

my $db = STG::DB->new({
                PROD => 0,
                SERVER=> $server_db,
                USERID=>'stgsec',
   });

my $date = localtime->strftime('%Y-%m-%d');

$html .= <<DESCRIPTION_TABLE;
	<center>
	<table style:'border-collapse: collapse; cellpadding="4" cellspacing="0" width="100%"'>
	<tr style='background-color: #dddddd;'>
		<th style='border: 1px solid #dddddd;' colspan="2"> STG IT Help Action Required </th>
	</tr>
	<tr>
		<td style='border: 1px solid #dddddd;'>
			<b>Group Assigned:</b>
		</td>
		<td style='border: 1px solid #dddddd;'>
			IT Security Support
                </td>
	</tr>
	<tr>
                <td style='border: 1px solid #dddddd;'>
                	<b>Subject:</b>
                </td>
                <td style='border: 1px solid #dddddd;'>
			The following tickets are either past due, will be due to be closed in the next 7 days, or they have been untouched for more than 1 week
                </td>
        </tr>
	<tr>
                <td style='border: 1px solid #dddddd;'>
                        <b>Action Required:</b>
                </td>
                <td style='border: 1px solid #dddddd;'>
                        Please review the tickets listed in the tables below. <br>
			Please remember: Problem Reports should be given higher priority than Work Items.
                </td>
        </tr>
	</table>
	</center>
	<br><br>
DESCRIPTION_TABLE

$html .= <<TICKET_DESCRIPTION;
	<h2> Tickets </h2>
	<p>
		<font size='4'><b style='color:red'>x</b></font> - Past required date. <br>
		<font size='4'><b style='color:green' size='15'>&#10003</b></font> - Still on time. <br>
		<font size='4'><b style='color:red' size='15'>&#9624</b></font> - "Days Without Activity" highlighted in red indicates not updated for more than 7 days.
	</p>
	<br>
TICKET_DESCRIPTION

$html .= <<TICKETS_TABLE;
	<table style:'border-collapse: collapse; cellpadding="4" cellspacing="0"'>
		<tr style='background-color: #dddddd;'>
			<th style='border: 1px solid #dddddd;'>  </th>
			<th style='border: 1px solid #dddddd;'> Ticket </th>			        
			<th style='border: 1px solid #dddddd;'> Type </th>
        		<th style='border: 1px solid #dddddd;'> State </th>
        		<th style='border: 1px solid #dddddd;'> Sev </th>
        		<th style='border: 1px solid #dddddd;'> Req Date </th>
        		<th style='border: 1px solid #dddddd;'> Person Assigned </th>
        		<th style='border: 1px solid #dddddd;'> Brief Description </th>
        		<th style='border: 1px solid #dddddd;'> Last Modifier </th>
        		<th style='border: 1px solid #dddddd;'> Last Update </th>
        		<th style='border: 1px solid #dddddd;'> Days Without Activity </th>
		</tr>
TICKETS_TABLE

my $sql = "SELECT * FROM SECDev.ithelp_tickets;";
my $data = $db->SQLQuery($sql);

foreach my $record (@{$data}){
	my $ticketOverdue = "";
	my $ticketActivity = "";
	my $format   = '%Y-%m-%d';
	my @reqDate  = split(" ", $record->{Required_Date});
	my @lastDate = split(" ", $record->{Last_Update} );
	my @perAssig = split(' \(', $record->{Person_Assigned});
	my @lastMod  = split('\(', $record->{Last_Modifier});
	my $daysDiff = int( (parsedate($date) - parsedate($lastDate[0])) / (60 * 60 * 24) );
	my $overdue  = int( (parsedate($date) - parsedate($reqDate[0])) / (60 * 60 * 24) );
	my $ticketLink = $itHelp . $record->{Ticket};

	if ($overdue > 0){
		$ticketOverdue = "<font size='4'><b style='color:red'>x</b></font>";
	}
	else{
		$ticketOverdue = "<font size='4'><b style='color:green'>&#10003</b></font>";
	}
	
	if($daysDiff > 7){
		$ticketActivity = "background-color: #ff3333;";
	}
	
	$html .= <<TICKET_ROW;
		<tr>
                	<td style='border: 1px solid #dddddd;'><center>$ticketOverdue</center></td>
                	<td style='border: 1px solid #dddddd;'><a href="$ticketLink" target="_blank"> $record->{Ticket} </a></td>
                	<td style='border: 1px solid #dddddd;'>$record->{Ticket_Type}</td>
                	<td style='border: 1px solid #dddddd;'>$record->{State}</td>
                	<td style='border: 1px solid #dddddd;'><center>$record->{Sev}</center></td>
                	<td style='border: 1px solid #dddddd;'>$reqDate[0]</td>
                	<td style='border: 1px solid #dddddd;'>$perAssig[0]</td>
                	<td style='border: 1px solid #dddddd;'>$record->{Brief_Description}</td>
                	<td style='border: 1px solid #dddddd;'>$lastMod[0]</td>
                	<td style='border: 1px solid #dddddd;'>$lastDate[0]</td>
                	<td style='border: 1px solid #dddddd; $ticketActivity'><center>$daysDiff</center></td>
        	</tr>
TICKET_ROW
}

$html .= "</table>";

my $mail = "True";
if ($mail eq "True"){
	my $msg = MIME::Lite->new(
        From    => $from,
        To      => $to,
        Cc      => $cc,
        Bcc     => $bcc,
        Subject => $subjet,
        Type    => 'multipart/mixed'
    );
	$msg->attach(
		Type => 'text/html',
		Data => $html
	);
	$msg->send;
}
