#!/usr/bin/perl
use strict;
use warnings;

use Schedule::At;
use DateTime;
use POSIX qw(strftime);
use List::Util qw( min max );
use RPi::WiringPi;
use Data::Dumper;
use DBI;
use MIME::Base64;
use Net::Ping;

require "admin.pl";

## setting vars
my $pi = RPi::WiringPi->new;
our ($ip, %db, %pins, %setup, $serverip, $ua);
our %states = (
    'on' => 0,
    'off' => 1,
);

sub getServerIp {
    my @addreses = split(/ /, `hostname -I`);
    return $addreses[0];
};

sub compareTimes {
    my $firsttime = shift;
    my @firsttime = split(/\:/, $firsttime);
    my $secondtime = shift;
#    print Dumper \$firsttime;
#    print Dumper \$secondtime;
    if ($secondtime && $secondtime =~ /^(\d+):(\d+)/ and $firsttime[1] >= $1 and $firsttime[1] >= $2) {
        return 1;
    }
    return 0;
};

sub timer {
    my $job = shift();
    my $timer = shift();
    my ($offtime);
    my $now = DateTime->now;
    my $date = $now->dmy('/');
    my $time = $now->hms;
    $now = $date . " " . $time;
    logging('heat', "$ip requested $job on for $timer at $now");
    if ( $timer < "25" && $timer > "0" ) {
        $timer = $timer * 3600;
    } else {
        $timer = $timer * 60;
    };
    $offtime = time() + $timer;
    Schedule::At::add (TIME => $offtime, COMMAND => "curl $serverip:5000/off", TAG => 'Timer off');#     /bin/bash /scripts/timed $timer $frame heat
    $offtime = strftime("%H:%M", $offtime);
    my $bcm = $setup{$job}{'BCM'};
    my $pin = $pi->("$bcm");
    $pin->write(0);#    gpio -g write 14 0
#     updateTimeDb($job, $next);
    $db{$job}{'state'} = 'on';#    echo "on" > /var/www/heat.txt
    $db{$job}{'off'} = $offtime;#    echo "truncate table heat" | $mysqll
    foreach my $job ( keys( %{ $db{atq} } ) ) {
        my $remaining = $job->{TIME} - time();
        if ( $job->{TAG} == 'OFF' && $remaining <= $timer) {
            Schedule::At::remove ($job->{JOBID});
        };
    };
    return 0;
};

sub on {
    my $job = shift;
    my $now = DateTime->now;
    my $date = $now->dmy('/');
    my $time = $now->hms;
    $now = $date . " " . $time;
    logging('heat', "$ip requested the $job on at $now");
    my @times;
    if ( ! $setup{$job} ) { return passOnJob($job); };
    my $bcm = $setup{$job}{'BCM'};
    my $pin = $pi->($bcm);
    foreach my $job ( keys( %{ $db{atq} } ) ) {
        #print Dumper $db{atq}{$job}{TAG};
        if ( $db{atq}{$job}{TAG} && $db{atq}{$job}{TAG} eq "OFF" ){
            push( @times, $db{atq}{$job}{TIME});
        };
    };
    my $next = min(@times);
#     updateTimeDb($job, $next);
    $db{$job}{'off'} = $next;
    $db{$job}{'on'} = undef;
    $db{$job}{'state'} = 'on';
    $pin->write(0);#
    return 0;
};

sub off {
    my $job = shift;
    my $now = DateTime->now;
    my $date = $now->dmy('/');
    my $time = $now->hms;
    $now = $date . " " . $time;
    logging('heat', "$ip requested the $job off");
    my @times;
    my $bcm = $setup{$job}{'BCM'};
    my $pin = $pi->($bcm);
    foreach my $job ( keys( %{ $db{atq} } ) ) {
        if ( $db{atq}{$job}{TAG} && $db{atq}{$job}{TAG} eq "ON" ){
            push( @times, $db{atq}{$job}{TIME});
        };
    };
    my $next = min(@times);
    #     updateTimeDb($job, $next);
    $db{$job}{'on'} = $next;
    $db{$job}{'off'} = undef;
    $db{$job}{'state'} = 'off';
    $pin->write(1);
    return 0;
};

sub control { # main function
    my $job = shift;
    my $operation = shift();
    my $timer = shift();
    if ($timer > 0) {
        timer($timer);
        return 0;
    };
    my $subref = \&$operation;
    &$subref->($job); # calls function specified in $operation (on|off)      
};

sub state {
    my $job = shift;
    if ( ! $pins{$setup{'pins'}{$job}{'BCM'}} ) {
        $pins{$setup{'pins'}{$job}{'BCM'}} = $pi->pin($setup{'pins'}{$job}{'BCM'});
    };
    my $pin = $pins{$setup{'pins'}{$job}{'BCM'}};
    my $state = $pin->read;
    $pi->cleanup;
    return $state;
};

sub humanState {
    my $job = shift;
    my $state = state($job);
    if ($state == 0) {
        $state = "on";
    } else {
        $state = "off";
    };
    return $state;
}

sub pid {
    return $$;
};

sub cpu {
    my @cpu = split( ' ', `cat /proc/stat | grep '^cpu '`);
    my $cpu = $cpu[1] + $cpu[2] + $cpu[3];
    return $cpu;
};

sub ram {
    my @ram = split( ' ', `free -h | sed -n '3p'| sed 's/\\s\\s*/ /g' | cut -d " " -f 3-4`);
    return @ram;
};

sub force {
    my $gpio = shift;
    my $state = shift;
    my $pin = $pi->pin($gpio);
    $pin->write($state);
    $state = $pin->read;
    if ($state == 1) {
        return 0;
    };
    return 1;
}

sub flip {
    my $pin = shift;

};

sub getCurrentQueue {
    return encode_json( \%{ $db{atq} } );
};

sub getConf {
    my $tempsetup = {%setup};
    delete $tempsetup->{"external"};
    return encode_json($tempsetup);
};

sub findOthers {
    my @ip = split(/\./, $serverip);
    pop(@ip);
    my $network = join(".", @ip);
    my @ips = map { $network . $_ } ( 2 .. 254 );
    my $timeout = 1;
    my $port = 7;
    my $p = Net::Ping->new( "syn", $timeout );
    $p->{port_num} = $port;
    $p->ping($_) for (@ips);
    while ( my ( $host, $rtt, $ip ) = $p->ack ) {
        if ( $ip eq $serverip ) { next; };
        my $response = $ua->get("http://$ip:5000/devquery");
        if (! $response->is_success) { next; };
        my $host = $response->content;
        $setup{'external'}{$host}{'ip'} = $ip;
        $response = $ua->get("http://$ip:5000/getconfig");
        if (! $response->is_success) { next; };
        my $content = $response->content;
        $setup{'external'}{$host}{'config'} = $content;
    };
    return;
};

sub passOnJob {
    my $job = shift();
    foreach my $device ( keys( %{ $setup{'external'} } ) ) {
        if ( ! $setup{'external'}{$device}{'jobs'}{$job} ) { return 1; };
        my $hostip = $setup{'external'}{$device}{'ip'};
        my $response = $ua->get("http://$ip:5000/on/$job");
        return $response->content;
    };
};

sub outsideTemp {
    my $response = $ua->get("$setup{'weatherapi'}{'url'}");
    if (! $response->is_success) {
        logging("system", "No response from weather api");
        return;
    };
    my $data = decode_json $response->content ;
    return $data->{'current'}{'temp_c'} . " &degC";
};

sub upstairsTemp {
    return 30;
};

sub downstairsTemp {
    return 30;
};

sub nextState {
    my $job = shift;
    my ($sec,$minute,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $next = "off";
    if ( $db{$job}{'on'} ) {
        $next = "on";
    };
    my $valid = compareTimes("$hour:$minute", $db{$job}{$next});
    if ( $valid == 1){
        return "$job will turn $next at $db{$job}{$next}";
    };
    my $dsn = "DBI:mysql:database=$setup{'db'}{'db'};host=$setup{'db'}{'host'}";
    my $dbh = DBI->connect($dsn, $setup{'db'}{'user'}, decode_base64($setup{'db'}{'pass'}));
    my $prepare = $dbh->prepare("SELECT * FROM next WHERE job = \"$job\"");
    $prepare->execute();
    while (my @row = $prepare->fetchrow_array()) {
       $db{$job}{"on"} = $row[1];
       $db{$job}{"off"} = $row[2];
    };
    $dbh->disconnect();
    $next = "off";
    if ( $db{$job}{'on'} ) {
        $next = "on";
    };
    $valid = compareTimes("$hour:$minute", $db{$job}{$next});
#    print Dumper \%db;
    if ( $valid == 1){
        return "$job will turn $next at $db{$job}{$next}";
    };
    return 1;
};

sub test {
    my $sub = "nextState";
    my $jobref = \&$sub;
    return &$jobref("heat");
}

1;
