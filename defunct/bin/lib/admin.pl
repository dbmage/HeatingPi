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

## setting vars
our ($ip, %db, %setup, $serverip, $ua);
my @logs = qw(water heat webui pisystem);
my $now = DateTime->now;
my @mysql = (); # decode_base64

## open log file
open(my $logfile, '>>', "/var/log/heat.log");

sub logging {
    my $logfile = shift;
    my $logline = shift;
    my $logtime = strftime "%Y-%m-%d %H:%M:%S", localtime;
    my $caller = (caller(2))[3];
    my $line = sprintf("[%-19s][%-20s][%s]\n", $logtime, $caller, $logline);
    open(my $log, ">>", "/var/log/$logfile.log") || die("Unable to open $logfile.log");
    print $log $line;
    close $log;
}

sub createJobQueue {
    my $dsn = "DBI:mysql:database=$setup{'db'}{'{db'};host=$setup{'db'}{'host'}";
    my $dbh = DBI->connect($dsn, $setup{'db'}{'user'}, decode_base64($setup{'db'}{'pass'})); # or die("Unable to connect to DB $dbh->errstr()";
    my $dow = $now->day_name();
    my $month = sprintf("%02d", $now->month());
    my $day = sprintf("%02d", $now->day());
    for my $function ( keys( %{ $setup{jobs} } ) ) {
        my $table = $setup{'sets'}{$function};
        for my $jobtype ( keys( %{ $setup{jobs}{$function} } ) ) {
            for my $job ( @{ $setup{jobs}{$function}{$jobtype} } ) {
                my $select = "SELECT $job FROM $table WHERE DAY = \"$dow\"";
                my $prepare = $dbh->prepare($select);
                $prepare->execute();
                while (my @row = $prepare->fetchrow_array()) {
                    if ( $row[0] eq ""){ next; };
                    my $time = $now->year() . $month . $day;
                    $time .= $row[0] . "00";
                    my $command = $setup{"commands"}{$jobtype} . "/" . $function;
                    #at( add(TIME => $time, COMMAND => $setup{"commands"}{$jobtype}, TAG => $job) );
                    print Dumper "$time - $command - $job";
                };
            };
        };
    };
    #at( add(TIME => '00:00:00', COMMAND => 'curl http://127.0.0.1:5000/admin/midnight', TAG => 'midnight') );
#    print Dumper "00:00:00 - curl http://127.0.0.1:5000/admin/midnight - midnight";
    logging("pisystem", "Job queue created.");
    $dbh->disconnect();
};

## roll the log files
sub logRoll {
    my $date = $now->dmy('/');
    for ( @logs ) {
        open(my $log, ">>", "/var/log/$_.log");
        print $log "$date\n";
        close $log;
    };
    return 0;
};

## set all pins to normal state, ready for next day.
sub failSafe {
    for my $item ( keys( %{ $setup{'pins'} } ) ) {
        my $resetpin = $setup{'pins'}{$item}{'BCM'};
        my $time = $now->hms;
        my $force = force($resetpin, 1);
        while ( $force != 1 ) {
            $force = force($resetpin, 1);
        }
        logging('pisystem', "pin $resetpin ($item) turned off.");
    };
    refreshJobDb();
    clearAtQueue();
};

sub clearAtQueue {
    for my $job ( keys( %{ $db{atq} } ) ) {
        #Schedule::At::remove ($job->{JOBID});
        print("Removing job $job->{JOBID}");
    };
    logging("pisystem", "Job queue cleared.");
};

sub refreshJobDb {
    if (! $db{refresh} || time() - $db{qrefresh} > 300 ) {
        if ( $db{atq} ) {
            delete $db{atq};
            logging("pisystem", "Deleted job queue.");
        };
        %{ $db{atq} }= Schedule::At::getJobs();
        logging("pisystem", "Job queue refreshed.");
        $db{qrefresh} = time();
    };
};

sub getPins {
    if ( $setup{'pins'} ) { undef($setup{'pins'}) };
    my $dsn = "DBI:mysql:database=Pins;host=$setup{'db'}{'host'}";
    my $dbh = DBI->connect($dsn, $setup{'db'}{'user'}, decode_base64($setup{'db'}{'pass'}));
    my $hostname = `hostname`;
    $hostname = lc($hostname);
    my $prepare = $dbh->prepare("select * from sasuke");
    $prepare->execute();
    while (my @row = $prepare->fetchrow_array()) {
        shift(@row);
        my $hashref = \%{ $setup{'pins'}{$row[0]} };
        $hashref->{'physical'} = $row[1];
        $hashref->{'BCM'} = int($row[2]);
        $hashref->{'Wpi'} = int($row[3]); 
        $hashref->{'Name'} = $row[4];
        $hashref->{'Mode'} = int($row[5]);
        $hashref->{'Use'} = $row[6];
    };
    $dbh->disconnect();
};

1;
