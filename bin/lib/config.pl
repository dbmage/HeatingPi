#!/usr/bin/perl
use strict;
use warnings;

use Schedule::At;
use Net::Ping;

our %setup = (
    "db"      => {
        "host"  => "127.0.0.1", 
        "db" => "timer", 
        "user"  => "root", 
        "pass"  => "eXN0OTQq",
    },
    "sets"    => {
        "heating"  => 'Set1',
        "hotwater" => 'Set1',
    },
    "program" => {
        "heating"  => 1,
        "hotwater" => 0,
    },
    "jobs"    => {
        "heating"  => {
            "on"   => [ qw(CHON1 CHON2 CHON3 CHON4 CHON5) ],
            "off"  => [ qw(CHOFF1 CHOFF2 CHOFF3 CHOFF4 CHOFF5) ],
        },
        "hotwater" => {
            "on"   => [ qw(HWON1 HWON2 HWON3 HWON4 HWON5) ],
            "off"  => [ qw(HWOFF1 HWOFF2 HWOFF3 HWOFF4 HWOFF5) ],
        },
    },
    "pins" => {
        "light" => 3,
        "fan"   => 2,
    },
    "queues"  => {
        "heating"  => {
            "on"   => "h",
            "off"  => "g",
        },
        "hotwater" => {
            "on"   => "w",
            "off"  => "r",
        },
    },
    "commands" => {
        "on"   => "curl 127.0.0.1:5000/on",
        "off"  => "curl 127.0.0.1:5000/off",
    },
    'weatherapi' => {
        "url" => "http://api.apixu.com/v1/forecast.json?key=034324e08c9e47e7811155453170409&q=ig11",
    },
);

sub at { Schedule::At:: };

1;
