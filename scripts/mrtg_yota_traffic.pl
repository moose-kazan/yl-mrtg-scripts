#!/usr/bin/perl

# Author: Vadim Kalinnikov
# E-Mail: moose@ylsoftware.com
#
# Licensed under terms and conditions of GNU LGPL v3.0
#
# Description:
#     MRTG script for getting data from Yota modem/router
#     Tested with devices:
#
#     15a9:002d Gemtek WLTUBA-107 [Yota 4G LTE]
#         Firmware:   YRMR1_1.09
#         DeviceName: Modem YOTA 4G LTE
#
#     15a9:002d Gemtek WLTUBA-107 [Yota 4G LTE]
#         Firmware:   YRWMR1_1.16
#         DeviceName: Wi-Fi Modem YOTA 4G LTE


use strict;
use warnings;
use diagnostics;

use LWP::UserAgent;
use Getopt::Long;

my $yota_host;

GetOptions(
	"host=s" => \$yota_host
);

if (!$yota_host) {
	print <<USAGE;
Usage:
	$0 --host=\<IP_OF_MODEM\>

Example:
	$0 --host=10.0.0.1

USAGE
	exit 1;
}

my $result = {
	SentBytes => 0,
	ReceivedBytes => 0,
	ConnectedTime => 0
};

eval {
	# Try to get token and session_id
	# Note! If token not fount it may be not bad!
	my $ua = LWP::UserAgent->new(
		agent => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"
	);

	# New request
	my $req = HTTP::Request->new("GET" => "http://$yota_host/cgi-bin/sysconf.cgi?page=ajax&action=get_status");
	# Main headers
	$req->header("Origin" => "http://$yota_host");
	$req->header("Referer" => "http://$yota_host/");
	$req->header("X-Requested-With" => "XMLHttpRequest");
	# Process request
	my $response = $ua->request($req);
	# If success
	if ($response->is_success) {
		# Parse response
		%$result = split(/[=\n]/, $response->content);
	}
};

#use Data::Dumper;
#print Dumper($result);

print "$result->{ReceivedBytes}\n$result->{SentBytes}\n$result->{ConnectedTime}\n$yota_host\n";

