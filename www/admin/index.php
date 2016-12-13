<?php
include("/var/pp.php");
$wanip=shell_exec('dig +short myip.opendns.com @resolver1.opendns.com');;
$load = shell_exec('echo $(date +"%T")');
?>
<html>
<title>Admin Area</title>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style type="text/css">
a
{
position: relative;
left: 20px;
color: white;
font-size: 30px;
text-decoration: none;
}
a:visited
{
position: relative;
left: 20px;
color: white;
text-decoration: none;
}
a:hover
{
position: relative;
left: 20px;
color: red;
text-shadow:0 0 8px #0ff, 0px 0px 25px #00f, 0 0 50px #fff;
text-decoration: none;
}
body
{
background-color: black;
width: 300px;
color: white;

}
td, th
{
border-collapse: collapse;
border-bottom: 1px solid white;
color: white;
font-size: 20px;
text-align: center;
}
table, th
{
border-collapse: collapse;
border: 1px solid white;
color: white;
font-size: 20px;
text-align: center;
}
a.back
{
font-size:25px;
color: white;
text-decoration: none;
left: 0px;
}
a.back:visited
{
left: 0px;
color: white;
text-decoration: none;
}
a.back:hover
{
left: 0px;
color: red;
text-shadow:0 0 8px #0ff, 0px 0px 25px #00f, 0 0 50px #fff;
text-decoration: none;
}
div.queue
{
width: 310px;
}
</style>
</head>
<body>
<a class="back" href="../">Back</a><br>
<a href="https://<?php echo $wanip; ?>:10000">Webmin</a><br>
<a href="http://<?php echo $wanip;?>/admin/pma">Schedule Admin</a><br>
<a href="readall.php">Pin states</a><br>
<a href="logs.php">Log files</a><br><br>

<form method="POST" action=''>
<input type="submit" name="time" value="Correct The Time">
</form>
<form method="POST" action=''>
<input type="submit" name="queue" value="Current Queue">
</form>
<?php

if (isset($_POST["add"]))
{
$old_path = getcwd();
chdir('/scripts/');
$timer = shell_exec('/bin/bash timer');
chdir($old_path);
echo $timer;
//echo "<script>window.location = 'http://$wami/admin'</script>";
}
if (isset($_POST["time"]))
{
$ntpstop = shell_exec('sudo service ntp stop >> /var/log/timeup.log');
echo $ntpstop;
$timeupdate = shell_exec('sudo ntpdate ntp1.isp.sky.com >> /var/log/timeup.log');
echo $timeupdate;
$ntpstart = shell_exec('sudo service ntp start >> /var/log/timeup.log');
echo $ntpstart;
}
if (isset($_POST["queue"]))
{
$queue = shell_exec('sudo atq | grep $(date +%a) | sort -k 5,5');
echo "<div class='queue'><pre>$queue</pre></div>";
}

?>
<?php
/*
$servername = "localhost";
$username = "user";
$password = "password";
$dbname = "mysql";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
     die("Connection failed: " . $conn->connect_error);
}
$sql = "SELECT * FROM pins";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
     echo "<table>";
	echo "<tr><th>Pin (BCM)</th><th>Use</th></tr>";
     // output data of each row
     while($row = $result->fetch_assoc()) {
         echo "<tr><td>" . $row["Pin"]. "</td><td>" . $row["Use"]. "</td></tr>";
     }
     echo "</table>";
} else {
     echo "0 results";
}

$conn->close();
echo "<br><br>";
*/
echo "<h2>Loaded at " .$load."</h2>";
?>
</body>
</html>
