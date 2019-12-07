#!/usr/bin/perl

# Author: Vadim Kalinnikov
# E-Mail: moose@ylsoftware.com
#
# Licensed under terms and conditions of GNU LGPL v3.0
#
# Description:
#     MRTG script for getting data from TP-Link MiFi routers
#
#     Notice: this support ONLY incoming traffic
#
#     Tested with devices:
#         Name:               M7200
#         Hardware version:   M7200(EU) v1.0
#         Software version:   11.182.61.00.778

use strict;
use warnings;
use diagnostics;

use LWP::UserAgent;
use Getopt::Long;
use JSON;

my $hilink_host;
my $report_type = "";

GetOptions(
	"host=s" => \$hilink_host,
	"report=s" => \$report_type
);

if (!$hilink_host || $report_type !~ m{^(battery|wan)$}) {
	print <<USAGE;
Usage:
	$0 --host=\<IP_OF_MODEM\> --report=\<battery|wan\>

Example:
	$0 --host=192.168.0.1 --report=wan

USAGE
	exit 1;
}

my $result = {
	CurrentDownload => 0,
	CurrentUpload => 0,
	CurrentConnectTime => 0
};

eval {
	my $ua = LWP::UserAgent->new(
		agent => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"
	);

	# New request
	my $req = HTTP::Request->new("POST" => "http://$hilink_host/cgi-bin/web_cgi");
	# Main headers
	$req->header("Accept" => "application/json, text/javascript, */*; q=0.01");
	$req->header("Origin" => "http://$hilink_host");
	$req->header("Referer" => "http://$hilink_host/login.html");
	$req->header("Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8");
	$req->header("X-Requested-With" => "XMLHttpRequest");
	$req->header("Cookie" => "check_cookie=check_cookie");
	$req->content('{"module":"status","action":0}');
	# Process request
	my $response = $ua->request($req);
	# If success
	if ($response->is_success) {
		# Parse response. JSON keys:
		# for $report_type=wan: wan.totalStatistics
		# for $report_type=battery: battery.voltage
		my $parsed_data = JSON->new->utf8->decode($response->content);
		if ($report_type eq "wan") {
			$result->{CurrentDownload} = int $parsed_data->{wan}->{totalStatistics};
		}
		elsif ($report_type eq "battery") {
			$result->{CurrentDownload} = int $parsed_data->{battery}->{voltage};
		}
	}
};
print "$result->{CurrentDownload}\n$result->{CurrentUpload}\n$result->{CurrentConnectTime}\n$hilink_host\n";

