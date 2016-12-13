<?php
$wami = ".";
$myurl = "http://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
if (strpos($myurl,'http://192.168.0.11') !== false){
echo "";
} elseif ( isset( $_COOKIE['userlogin'] ) ) {;
echo "";
} else {
include("/var/pp1.php");
}

$cush = $_POST["cush"];
$cusw = $_POST["cusw"];


if (isset($_POST["heaton"]))
{
$old_path = getcwd();
chdir('/scripts/');
$heat = shell_exec('./heat on');
chdir($old_path);
echo "<script>window.location = '$wami'</script>";
}

if (isset($_POST["heaton1"]))
{
$old_path = getcwd();
chdir('/scripts/');
$heat = shell_exec('./heat on 30');
chdir($old_path);
echo "<script>window.location = '$wami'</script>";
}

if (isset($_POST["heaton2"]))
{
$old_path = getcwd();
chdir('/scripts/');
$heat = shell_exec('./heat on '.$cush);
chdir($old_path);
echo "<script>window.location = '$wami'</script>";
}

if (isset($_POST["heatoff"]))
{
$old_path = getcwd();
chdir('/scripts/');
$heat = shell_exec('./heat off');
chdir($old_path);
echo "<script>window.location = '$wami'</script>";
}
/*
if (isset($_POST["wateron"]))
{
$old_path = getcwd();
chdir('/scripts/');
$heat = shell_exec('./water on');
chdir($old_path);
echo "<script>window.location = '$wami'</script>";
}

if (isset($_POST["wateron1"]))
{
$old_path = getcwd();
chdir('/scripts/');
$heat = shell_exec('./water on 30');
chdir($old_path);
echo "<script>window.location = '$wami'</script>";
}

if (isset($_POST["wateron2"]))
{
$old_path = getcwd();
chdir('/scripts/');
$heat = shell_exec('./water on '.$cusw);
chdir($old_path);
echo "<script>window.location = '$wami'</script>";
}

if (isset($_POST["wateroff"]))
{
$old_path = getcwd();
chdir('/scripts/');
$heat = shell_exec('./water off');
chdir($old_path);
echo "<script>window.location = '$wami'</script>";
}

if (isset($_POST["box"]))
{
$heat = shell_exec('./relay 23');
echo "<script>window.location = '$wami'</script>";
}

if (isset($_POST["gate"]))
{
$heat = shell_exec('./relay 24');
echo "<script>window.location = '$wami'</script>";
}

if (isset($_POST["thermo"]))
{
$heat = shell_exec('./relay 18');
echo "<script>window.location = '$wami'</script>";
}
*/
$relay = $_GET['relay'];
if (!empty($relay)) {
        if ($relay == 'on') {
                $old_path = getcwd();
                chdir('/scripts/');
                $heat = shell_exec('./heat on');
                chdir($old_path);

        }
        if ($relay == '30') {
                $old_path = getcwd();
                chdir('/scripts/');
                $heat = shell_exec('./heat on 30');
                chdir($old_path);
        }
        if ($relay == 'off') {
                $old_path = getcwd();
                chdir('/scripts/');
                $heat = shell_exec('./heat off');
                chdir($old_path);
        }
}


$client = $_SERVER['REMOTE_ADDR'];
shell_exec('echo "Page loaded from ' . $client .' at $(date +%T)" >> /var/log/webui.log; echo "" >> /var/log/webui.log');
$nextonh = shell_exec('sudo atq -q h | sort -k 6n -k 3M -k 4n -k 5 -k 7 -k 1 | sed "s/  / /g" | cut -f 2 | cut -d " " -f4 | cut -d ":" -f1-2 | head -1');
$nextoffh = shell_exec('sudo atq -q g | sort -k 6n -k 3M -k 4n -k 5 -k 7 -k 1 | sed "s/  / /g" | cut -f 2 | cut -d " " -f4 | cut -d ":" -f1-2 | head -1');
/*$nextonw = shell_exec('sudo atq -q w | sort -k 6n -k 3M -k 4n -k 5 -k 7 -k 1 | sed "s/  / /g" | cut -f 2 | cut -d " " -f4 | cut -d ":" -f1-2 | head -1');
$nextoffw = shell_exec('sudo atq -q r | sort -k 6n -k 3M -k 4n -k 5 -k 7 -k 1 | sed "s/  / /g" | cut -f 2 | cut -d " " -f4 | cut -d ":" -f1-2 | head -1');
*/
$onh = shell_exec('cat onh.txt');
/*$onw = shell_exec('cat onw.txt');*/
$sth = shell_exec('cat /sys/class/gpio/gpio14/value');
$stw = shell_exec('cat /sys/class/gpio/gpio15/value');
$stt = shell_exec('cat /sys/class/gpio/gpio18/value');
$stb = shell_exec('cat /sys/class/gpio/gpio23/value');
$stg = shell_exec('cat /sys/class/gpio/gpio24/value');
$load = shell_exec('echo $(date +"%T")');

if ($sth == 1) {
	$himg = "off.png";
        if (empty($nextonh)) {
		if (!empty($nextoffh)) {
                	file_put_contents("onh.txt", "On: none   ");
                	file_put_contents("onh.txt", "Off at: $nextoffh", FILE_APPEND);
        	} else {
			file_put_contents("onh.txt", "On: none   ");
                	file_put_contents("onh.txt", "Off at: 23:45", FILE_APPEND);
		}
	} else {
                file_put_contents("onh.txt", "On: $nextonh   ");
                file_put_contents("onh.txt", "Off at: $nextoffh", FILE_APPEND);
        }
} else {
        $himg = "on.png";
        if (empty($nextoffh)) {
                if (strpos(file_get_contents(onh.txt), 'The Heating is on until:')) {
                        file_put_contents("onh.txt", " Off at: 23:45", FILE_APPEND);
                } else {
                        file_put_contents("onh.txt", "Off at: 23:45");
                }
        } else {
                if (strpos(file_get_contents(onh.txt), 'The Heating is on until:')) {
                        file_put_contents("onh.txt", " Off at: $£nextoffh", FILE_APPEND);
                } else {
                        file_put_contents("onh.txt", "Off at: $nextoffh");
                }
        }
}
/*if ($stw == 1) {
        $wimg = "off.png";
        if (empty($nextonw)) {
		if (!empty($nextooffw)) {
	                file_put_contents("onw.txt", "On: none   ");
        	        file_put_contents("onw.txt", "Off at: $nextoffw", FILE_APPEND);
		} else {
			file_put_contents("onw.txt", "On: none   ");
                        file_put_contents("onw.txt", "Off at: 23:45", FILE_APPEND);
		}
        } else {
                file_put_contents("onw.txt", "On: $nextonw   ");
                file_put_contents("onw.txt", "Off at: $nextoffw", FILE_APPEND);
        }
} else {
	$wimg = "on.png";
        if (! empty($nextoffw)) {
		if (strpos(file_get_contents(onw.txt), 'The Hot Water is on until:')) {
			file_put_contents("onw.txt", " Off at: $nextoffw", FILE_APPEND);
		} else {
			file_put_contents("onw.txt", " Off at: $nextoffw");
		}
	} else {
		if (strpos(file_get_contents(onw.txt), 'The Hot Water is on until:')) {
			file_put_contents("onw.txt", " Off at: 23:45", FILE_APPEND);
		} else {
			file_put_contents("onw.txt", "Off at: 23:45");
		}
        }
}
if ($stt == 1) {
$timg = "red";
} else {
$timg = "blue";
}
if ($stb == 0) {
$bimg = "red";
}
if ($stg == 0) {
$gimg = "red";
}*/
?>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="Content-type" content="text/html;charset=UTF-8">
<link rel="stylesheet" type="text/css" href="dave.css">
<style type="text/css">
body
{
width: 500px;
}
.therm
{
background-color: <?php echo $timg; ?>;
}
.box
{
background-color: <?php echo $bimg; ?>;
}
.gate
{
background-color: <?php echo $gimg; ?>;
}
</style>
</head>
<body  style="color:white;">
<div class="body">
<a class="admin" href="admin/"><button>Admin</button></a>
<a class="schedule" href="schedule.php"><button>Schedule</button></a><?php echo "<a> Loaded " .$load."</a>"; ?><hr>
<d style="font-weight:bold;">Heating Control</d><d>Status: <img src="<?php echo "$himg"; ?>" width="30px" height="30px"></d>
<form method="POST" action=''>
<input type="submit" name="heaton" value="On">
<input type="submit" name="heaton1" value="30">
<input type="submit" name="heatoff" value="Off">
<br>
<d>Custom Timer:</d><input class="timebox" type="text" size="5" name="cush">
<input class="nopad" type="submit" name="heaton2" value="Set Timer"></form>
<c><?php echo "$onh"; ?></c><br><br>
<!--<d style="font-weight:bold;">Hot Water Control</d><d>Status:</d><img src="<?php echo "$wimg"; ?>" width="30px" height="30px">
<form method="POST" action=''>
<input type="submit" name="wateron" value="On">
<input type="submit" name="wateron1" value="30">
<input type="submit" name="wateroff" value="Off">
<br>
<d>Custom Timer:</d><input class="timebox" type="text" size="5" name="cusw">
<input class="nopad" type="submit" name="wateron2" value="Set Timer">
</form>
<c><?php echo "$onw"; ?></c><br><br>
<form method="POST" action=''>
<input class="therm" type="submit" name="thermo" value="Thermostat">
<input class="box" type="submit" name="box" value="Box">
<input class="gate" type="submit" name="gate" value="Gate">
</form>-->
</div>
</body>
</html>
