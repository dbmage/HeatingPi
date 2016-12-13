<?php
$wami = ($_SERVER['SERVER_NAME']);
if ( $_SERVER['REQUEST_METHOD'] == 'POST' )
{
	if (isset($_POST['schedule']))
	{
	$set = $_POST["schedule"];
	$inuse = file_get_contents("/var/www/active");
//echo "POST SCHEDULE";
	}
	elseif (isset($_POST['setsch']))
	{
	$inuse = $_POST["setsch"];
	$change = shell_exec("echo " . $inuse . " > /var/www/active");
//echo "POST SETSCH";
	$set = $inuse;
	}
}
else
{
//echo "active is cat of file";
$inuse = file_get_contents("/var/www/active");
$set = file_get_contents("/var/www/active");
}

$toggle = "${inuse}c";
$toggle = preg_replace('/\s+/', '', $toggle);
$toggle = strtolower($toggle);
$$toggle = "checked";

?>
<html>
<head>
<title>Heating/Water Schedule Management</title>
<style>
body
{
color: #A0A0A0;
background-color: black;
}
table
{
    margin-left: auto;
    margin-right: auto;
    width: 80%;
    text-align: center;
    border: 1px solid white;
    font-size: 25px;
}
div.select
{
position: fixed;
right: 0px;
top: 0px;
text-align:right;
}
a.select
{
font-weight: bold;
}
.day
{
text-align: left;
}
</style>
</head>
<body>
<a href="http://<?php echo $wami; ?>"><button>Control</button></a>
<br>
<h3>Select the schedule you would like to view:</h3>
<form method="POST" action=''>
<select name="schedule">
<option value="Set1">Set 1</option>
<option value="Set2">Set 2</option>
<option value="Set3">Set 3</option>
<option value="Set4">Set 4</option>
</select>
<button type="submit">View</button>
</form>
<div class="select">
<a class="select">Select the active Set<br>(currently active is selected)</a>
<form method="POST" action=''>
  <input type="radio" name="setsch" value="Set1" <?php echo "$set1c"; ?> >Set 1
  <br>
  <input type="radio" name="setsch" value="Set2" <?php echo "$set2c"; ?> >Set 2
  <br>
  <input type="radio" name="setsch" value="Set3" <?php echo "$set3c"; ?> >Set 3
  <br>
  <input type="radio" name="setsch" value="Set4" <?php echo "$set4c"; ?> >Set 4
<br>
<button type="submit">Change</button>
</form></div>
<?php
$servername = "localhost";
$username = "root";
$password = "yst94*";
$dbname = "timer";
?>
<h1></h1>
<?php
//echo "table set: $set<br>";
//echo "active set: $inuse<br>";
//echo "setc : 1 $set1c 2 $set2c 3 $set3c 4 $set4c<br>";
//echo "<br>";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
     die("Connection failed: " . $conn->connect_error);
}
$sql = "SELECT * FROM $set";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
     echo "<table>";
     echo "<th colspan=9>Currently showing: " . $set . "</th><th colspan=10>Currently active: " . $inuse . "</th>";
     // output data of each row
     while($row = $result->fetch_assoc()) {
         echo "<tr><td class='day'>" . $row["DAY"]. "</td><td>" . $row["CHON1"]. "</td><td>" . $row["CHOFF1"]. "</td><td>" . $row["CHON2"]. "</td><td>" . $row["CHOFF2"]. "</td><td>" . $row["CHON3"]. "</td><td>" . $row["CHOFF3"]. "</td><td>" . $row["CHON4"]. "</td><td>" . $row["CHOFF4"]. "</td><td>" . $row["CHON5"]. "</td><td>" . $row["CHOFF5"]. "</td><td>" . $row["HWON1"]. "</td><td>" . $row["HWOFF1"]. "</td><td>" . $row["HWON2"]. "</td><td>" . $row["HWOFF2"]. "</td><td>" . $row["HWON3"]. "</td><td>" . $row["HWOFF3"]. "</td><td>" . $row["HWON4"]. "</td><td>" . $row["HWOFF4"]. "</td></tr>";
     }
     echo "</table>";
} else {
     echo "0 results";
}

$conn->close();
?>

</body>
</html>
