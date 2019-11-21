#!/usr/bin/perl

# Author: Vadim Kalinnikov
# E-Mail: moose@ylsoftware.com
#
# Description: MRTG script for get data from NUT
#

use strict;
use warnings;
use diagnostics;

use Getopt::Long;

use UPS::Nut;

my $ups_host;
my $ups_name;
my $ups_username = "";
my $ups_password = "";
my $ups_key1;
my $ups_key2;

GetOptions(
	"host=s" => \$ups_host,
	"name=s" => \$ups_name,
	"user=s" => \$ups_username,
	"pass=s" => \$ups_password,
	"key1=s" => \$ups_key1,
	"key2=s" => \$ups_key2,
);

if (!$ups_host || !$ups_name || !$ups_key1 || !$ups_key2) {
	print <<USAGE;
Usage:
	$0 \<params\>

Available params:

	--name=ups_name (required)
	--host=hostname (required)
	--user=username (optional. default: no username)
	--pass=password (optional. default: empty password)
	--key1 (required)
	--key2 (required)
USAGE
	exit 1;
}

my $ups = new UPS::Nut(
	NAME => $ups_name,
	HOST => $ups_host,
	USERNAME => $ups_username,
	PASSWORD => $ups_password,
) or die("Can't connect to UPS!\n");

my $ups_key1_value = $ups->Request("$ups_key1");
my $ups_key2_value = $ups->Request("$ups_key2");

print sprintf("%d\n", $ups_key1_value ? $ups_key1_value : 0);
print sprintf("%d\n", $ups_key2_value ? $ups_key2_value : 0);
