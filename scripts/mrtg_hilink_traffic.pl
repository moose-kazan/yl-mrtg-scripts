#!/usr/bin/perl

# Author: Vadim Kalinnikov
# E-Mail: moose@ylsoftware.com
#
# Licensed under terms and conditions of GNU LGPL v3.0
#
# Description:
#     MRTG script for getting data from Huawei HiLink modem/router
#     Tested with devices:
#         Name:               B525s-23a
#         Hardware version:   WL1B520FM
#         Software version:   11.182.61.00.778
#         WebUI version:      21.100.36.00.03
#
#         Name:               MTS 829FT (Huawei E3372h-153)
#         Hardware version:   CL2E3372HM
#         Software version:   22.333.63.00.143
#         WebUI version:      17.100.20.02.143
#
#         Name:               Huawei E3272s-210
#         Hardware version:   CH2E3272SM
#         Software version:   22.491.03.00.1307
#         WebUI version:      17.100.08.00.1307
#
#         Name:               Huawei E3272s-153
#         Hardware version:   CH1E3272SM
#         Software version:   22.436.07.02.161
#         WebUI version:      13.100.04.03.161
#
#         Name:               Huawei E8372s-153
#         Hardware version:   CL1E8372HM
#         Software version:   21.333.63.01.778
#         WebUI version:      17.100.21.02.778
#
#         Name:               Tele2 RUS 4G (Huawei E3372h-153)
#         Hardware version:   CL2E3372HM
#         Software version:   22.328.62.01.391
#         WebUI version:      17.100.19.01.391
#
#         Name:               MTS 8213FT (Huawei E5785LH-22C)
#         Hardware version:   CL1E5785SM
#         Software version:   21.187.63.00.143
#         WebUI version:      21.100.42.00.143

use strict;
use warnings;
use diagnostics;

use LWP::UserAgent;
use Getopt::Long;

my $hilink_host;

GetOptions(
	"host=s" => \$hilink_host
);

if (!$hilink_host) {
	print <<USAGE;
Usage:
	$0 --host=\<IP_OF_MODEM\>

Example:
	$0 --host=192.168.8.1

USAGE
	exit 1;
}

my $result = {
	CurrentDownload => 0,
	CurrentUpload => 0,
	CurrentConnectTime => 0
};

eval {
	# Try to get token and session_id
	# Note! If token not fount it may be not bad!
	my $ua = LWP::UserAgent->new(
		agent => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"
	);
	my $response = $ua->get("http://$hilink_host/api/webserver/SesTokInfo");
	my $token;
	my $session_id;
	if ($response->content =~ m{<TokInfo>(.+?)</TokInfo>}) {
		$token = $1;
	}
	if ($response->content =~ m{<SesInfo>SessionID=(.+?)</SesInfo>}) {
		$session_id = $1;
	}


	# New request
	my $req = HTTP::Request->new("GET" => "http://$hilink_host/api/monitoring/traffic-statistics");
	# Main headers
	$req->header("Origin" => "http://$hilink_host");
	$req->header("Referer" => "http://$hilink_host/html/home.html");
	$req->header("X-Requested-With" => "XMLHttpRequest");
	# Token
	$req->header(":__RequestVerificationToken" => $token) if $token;
	# Session ID
	$req->header("Cookie" => "SessionID=$session_id") if $session_id;
	# Process request
	$response = $ua->request($req);
	# If success
	if ($response->is_success) {
		# Parse response
		foreach (keys %$result) {
			if ($response->content =~ m{<$_>(.+?)</$_>}) {
				$result->{$_} = $1;
			}
		}
	}
};
print "$result->{CurrentDownload}\n$result->{CurrentUpload}\n$result->{CurrentConnectTime}\n$hilink_host\n";

