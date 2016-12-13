<?php
$wami = "http://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
$heat = shell_exec('cat /var/log/heat.log | tail --lines=40');
$water = shell_exec('cat /var/log/water.log | tail --lines=40');
$webui = shell_exec('cat /var/log/webui.log | tail --lines=40');
$system = shell_exec('cat /var/log/pisystem.log | tail --lines=40');
$other = shell_exec('cat /var/www/log | tail --lines=50');
?>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-type" content="text/html;charset=UTF-8">
</head>
<body>
<form method="POST" action=''>
<input type= "submit" name="heat" value="Heat Log">
<input type= "submit" name="water" value="Water Log">
<input type= "submit" name="webui" value="Webui Log">
<input type= "submit" name="sys" value="System Log">
<input type= "submit" name="other" value="Other Logs">
</form>
<?php
if (isset($_POST["heat"]))
{
echo "<pre>$heat</pre>";
}

if (isset($_POST["water"]))
{
echo "<pre>$water</pre>";
}

if (isset($_POST["webui"]))
{
echo "<pre>$webui</pre>";
}
if (isset($_POST["sys"]))
{
echo "<pre>$system</pre>";
}
if (isset($_POST["other"]))
{
echo "<pre>$other</pre>";
}
?>
</body>
</html>
