package heating;
use Dancer2;

our $VERSION = '0.3';

use Schedule::At;
use DateTime;
use POSIX qw(strftime);
use List::Util qw( min max );
use RPi::WiringPi;
use Data::Dumper;
use DBI;
use MIME::Base64;
use LWP::UserAgent;
use Net::Ping;

our $ua = LWP::UserAgent->new;

do "config.pl";
require "functions.pl";
 
our ($ip, %db, %states, %pins, %setup, $serverip);
 
open(my $fh, '>', "/var/run/heating.pid");
print $fh $$;
close($fh);
 
$serverip = getServerIp();
#Create job db list
#refreshJobDb();
#Get pins from DB
getPins();
#find other controllers (pis)
#findOthers();
 
get '/' => sub {
    my $pid = pid();;
    my $cpu = cpu();
    my ($usedram, $freeram) = ram();
    my $heating = humanState('heating');
    my $heatnext = nextState("heat");
    my $water = humanState('water');
    my $waternext = nextState("water");
    return<<EOF;
    <br>
    <h2>Online  <img src="http://192.168.0.2/img/online.png" width="20px"></h2>
    <h3>Process ID: $pid </h3>
    <h3>CPU: $cpu</h3>
    <h3>RAM: $usedram / $freeram</h3>
    <h3>Heating: <img src="http://192.168.0.2/img/$heating.png" width="20px"></h3>
    <h4>$heatnext;</h4>
    <h3>Water: <img src="http://192.168.0.2/img/$water.png" width="20px"></h3>
    <h4>$waternext;</h4>
EOF
};
 
get '/devquery' => sub { return `hostname`; };
 
get '/getconfig' => sub { return getConf(); };
 
get '/state/' => sub {
    refreshJobDb();
    $ip = request->address();
    return state();
};
 
get '/timer/:timer' => sub {
    refreshJobDb();
    $ip = request->address();
    my $timer = route_parameters->get('timer');
    control('on', $timer);
};
 
get '/on/:job' => sub {
    my $job = route_parameters->get('job');
    refreshJobDb();
    $ip = request->address();
    control($job, 'on', '0');
};
 
get '/off/:job' => sub {
    my $job = route_parameters->get('job');
    refreshJobDb();
    $ip = request->address();
    control($job, 'off', '0');
};
 
get '/flip/:thing' => sub {
    refreshJobDb();
    my $thing = route_parameters->get('thing');
    $ip = request->address();
    my $pin = $setup{$thing};
    flip($pin);
};
 
get '/apiflip/:pin' => sub {
    refreshJobDb();
    my $pin = route_parameters->get('pin');
    $ip = request->address();
    flip($pin);
};
 
get '/getstateapp/:pin' => sub {
    my $pin = route_parameters->get('pin');
    true;
};
 
get '/atqueue/' => sub {
    return getCurrentQueue();
};
 
get '/admin/:job' => sub {
    my $job = route_parameters->get('job');
    my $jobref = \&$job;
    if (! defined &$jobref) { return 1; };
    return &$jobref();
};

get '/outtemp/' => sub {
    return outsideTemp();
};

get '/uptemp/' => sub {
    return upstairsTemp();
};

get '/downtemp/' => sub {
    return downstairsTemp();
};

true;
