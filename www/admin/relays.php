<html>
<title>Relay uses and layout</title>
<head>
<style type="text/css">
body
{
margin-left: auto;
margin-right: auto;
width: 400px;
}
th, td
{
width: 120px;
height: 50px;
text-align: center;
border: 1px solid black;
}
img
{
width: 20px;
}
</style>
</head>
<body>
<?php
$load = shell_exec('echo $(date +"%T")');

for ($a = 1; $a <= 16; $a++) {
$check = shell_exec('cat /sys/class/gpio/gpio' .$a. '/value');
${'r' .$a} = "";
	if ($check == "")
	{
	${'r' .$a} = "../off.png";
	}
	elseif ($check == 0)
	{
	${'r' .$a} = "../on.png";
	} else {
	${'r' .$a} = "../off.png";
	}
}
?>
<table>
  <tr>
    <th>On/Off</th>
    <th>Relay Use</th>
    <th>GPIO Pin</th>
    <th>GPIO Pin</th>
    <th>Relay Use</th>
    <th>On/Off</th>
  </tr>
  <tr>
    <th><img src="<?php echo "$r9";?>"></th>
    <td>None</td>
    <td>n/a</td>
    <td>n/a</td>
    <td>None</td>
    <th><img src="<?php echo "$r8";?>"></th>
  </tr>
  <tr>
    <th><img src="<?php echo "$r10";?>"></th>
    <td>None</td>
    <td>n/a</td>
    <td>n/a</td>
    <td>None</td>
    <th><img src="<?php echo "$r7";?>"></th>
  </tr>
  <tr>
    <th><img src="<?php echo "$r11";?>"></th>
    <td>None</td>
    <td>n/a</td>
    <td>n/a</td>
    <td>None</td>
    <th><img src="<?php echo "$r6";?>"></th>
  </tr>
  <tr>
    <th><img src="<?php echo "$r12";?>"></th>
    <td>None</td>
    <td>n/a</td>
    <td>n/a</td>
    <td>None</td>
    <th><img src="<?php echo "$r5";?>"></th>
  </tr>
  <tr>
    <th><img src="<?php echo "$r13";?>"></th>
    <td>None</td>
    <td>n/a</td>
    <td>n/a</td>
    <td>None</td>
    <th><img src="<?php echo "$r4"?>"></th>
  </tr>
  <tr>
    <th><img src="<?php echo "$r14";?>"></th>
    <td>Heating</td>
    <td>14</td>
    <td>n/a</td>
    <td>None</td>
    <th><img src="<?php echo "$r3";?>"></th>
  </tr>
  <tr>
    <th><img src="<?php echo "$r15";?>"></th>
    <td>Hot Water</td>
    <td>15</td>
    <td>n/a</td>
    <td>None</td>
    <th><img src="<?php echo "$r2";?>"></th>
  </tr>
  <tr>
    <th><img src="<?php echo "$r16";?>"></th>
    <td>None</td>
    <td>n/a</td>
    <td>n/a</td>
    <td>None</td>
    <th><img src="<?php echo "$r1";?>"></th>
  </tr>
</table>
<?php
echo "<a>Loaded at " .$load."</a>";
?>
</body>
</html>
