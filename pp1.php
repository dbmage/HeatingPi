<?php

###############################################################
# Page Password Protect 2.13
###############################################################
# Visit http://www.zubrag.com/scripts/ for updates
############################################################### 
#
# Usage:
# Set usernames / passwords below between SETTINGS START and SETTINGS END.
# Open it in browser with "help" parameter to get the code
# to add to all files being protected. 
#    Example: password_protect.php?help
# Include protection string which it gave you into every file that needs to be protected
#
# Add following HTML code to your page where you want to have logout link
# <a href="http://www.example.com/path/to/protected/page.php?logout=1">Logout</a>
#
###############################################################

/*
-------------------------------------------------------------------
SAMPLE if you only want to request login and password on login form.
Each row represents different user.

$LOGIN_INFORMATION = array(
  'zubrag' => 'root',
  'test' => 'testpass',
  'admin' => 'passwd'
);

--------------------------------------------------------------------
SAMPLE if you only want to request only password on login form.
Note: only passwords are listed

$LOGIN_INFORMATION = array(
  'root',
  'testpass',
  'passwd'
);

--------------------------------------------------------------------
*/

##################################################################
#  SETTINGS START
##################################################################

// Add login/password pairs below, like described above
// NOTE: all rows except last must have comma "," at the end of line
$LOGIN_INFORMATION = array(
  'PASSWORDGOESHERE',
);

// request login? true - show login and password boxes, false - password box only
define('USE_USERNAME', false);

// User will be redirected to this page after logout
define('LOGOUT_URL', 'http://www.example.com/');

// time out after NN minutes of inactivity. Set to 0 to not timeout
define('TIMEOUT_MINUTES', 0);

// This parameter is only useful when TIMEOUT_MINUTES is not zero
// true - timeout time from last activity, false - timeout time from login
define('TIMEOUT_CHECK_ACTIVITY', true);

##################################################################
#  SETTINGS END
##################################################################


///////////////////////////////////////////////////////
// do not change code below
///////////////////////////////////////////////////////

// show usage example
if(isset($_GET['help'])) {
  die('Include following code into every page you would like to protect, at the very beginning (first line):<br>&lt;?php include("' . str_replace('\\','\\\\',__FILE__) . '"); ?&gt;');
}

// timeout in seconds
$timeout = (TIMEOUT_MINUTES == 0 ? 0 : time() + TIMEOUT_MINUTES * 60);

// logout?
if(isset($_GET['logout'])) {
  setcookie("verify", '', $timeout, '/'); // clear password;
  header('Location: ' . LOGOUT_URL);
  exit();
}

if(!function_exists('showLoginPasswordProtect')) {

// show login form
function showLoginPasswordProtect($error_msg) {
?>
<?php
$client = $_SERVER['REMOTE_ADDR'];
shell_exec('echo "Login page loaded from ' . $client .' at $(date +%T)" >> /var/log/webui.log; echo "" >> /var/log/webui.log');
$nextonh = shell_exec('sudo atq -q h | sort -k 6n -k 3M -k 4n -k 5 -k 7 -k 1 | cut -f 2 | cut -d " " -f4 | cut -d ":" -f1-2 | head -1');
$nextoffh = shell_exec('sudo atq -q g | sort -k 6n -k 3M -k 4n -k 5 -k 7 -k 1 | cut -f 2 | cut -d " " -f4 | cut -d ":" -f1-2 | head -1');
$nextonw = shell_exec('sudo atq -q w | sort -k 6n -k 3M -k 4n -k 5 -k 7 -k 1 | cut -f 2 | cut -d " " -f4 | cut -d ":" -f1-2 | head -1');
$nextoffw = shell_exec('sudo atq -q r | sort -k 6n -k 3M -k 4n -k 5 -k 7 -k 1 | cut -f 2 | cut -d " " -f4 | cut -d ":" -f1-2 | head -1');
$sth = shell_exec('cat /sys/class/gpio/gpio14/value');
$stw = shell_exec('cat /sys/class/gpio/gpio15/value');
$stt = shell_exec('cat /sys/class/gpio/gpio18/value');
$stb = shell_exec('cat /sys/class/gpio/gpio23/value');
$stg = shell_exec('cat /sys/class/gpio/gpio24/value');
$onh = shell_exec('cat onh.txt');
$onw = shell_exec('cat onw.txt');
$load = shell_exec('echo $(date +"%T")');

if ($stw == 1) {
        $wimg = "off.png";
} else {
        $wimg = "on.png";
};
if ($sth == 1) {
        $himg = "off.png";
} else {
        $himg = "on.png";
};
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
}

?>

<html>
<head>
<title>Please enter password to access this page</title>
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
<link rel="stylesheet" type="text/css" href="dave.css">
<style>
input
{
border: 1px solid black;
}

body
{
background-color: black;
color: white;
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
<div style="width:350px; text-align:center">
<?php echo "<a> Loaded " .$load."</a>"; ?><br>
<form method="post">
    <h3>Please login</h3>
    <font color="red"><?php echo $error_msg; ?></font><br />
    <?php if (USE_USERNAME) echo 'Login:<br /><input type="input" name="access_login" /><br />Password:<br />'; ?>
    <input style="width: 150px; height: 40px;" type="password" name="access_password" /><p></p><input style=" height: 40px;" type="submit" name="Submit" value="Submit" />
</form>
<!--<a style="font-size:9px; color: #B0B0B0; font-family: Verdana, Arial;" href="http://www.zubrag.com/scripts/password-protect.php" title="Download Password Protector">Powered by Password Protect</a>-->
<d style="font-weight:bold;">Heating Control</d><d>Status: <img src="<?php echo "$himg"; ?>" width="30px" height="30px"></d><br>
<c><?php echo "$onh"; ?></c><br><br>
<d style="font-weight:bold;">Hot Water Control</d><d>Status:</d><img src="<?php echo "$wimg"; ?>" width="30px" height="30px"><br>
<c><?php echo "$onw"; ?></c><br><br>
<input class="therm" type="submit" name="thermo" value="Thermostat">
<input class="box" type="submit" name="box" value="Box">
<input class="gate" type="submit" name="gate" value="Gate">
  </div>
</body>
</html>

<?php
  // stop at this point
  die();
}
}

// user provided password
if (isset($_POST['access_password'])) {

  $login = isset($_POST['access_login']) ? $_POST['access_login'] : '';
  $pass = $_POST['access_password'];
  if (!USE_USERNAME && !in_array($pass, $LOGIN_INFORMATION)
  || (USE_USERNAME && ( !array_key_exists($login, $LOGIN_INFORMATION) || $LOGIN_INFORMATION[$login] != $pass ) ) 
  ) {
    showLoginPasswordProtect("Incorrect password.");
  }
  else {
    // set cookie if password was validated
    setcookie("verify", md5($login.'%'.$pass), $timeout, '/');
    
    // Some programs (like Form1 Bilder) check $_POST array to see if parameters passed
    // So need to clear password protector variables
    unset($_POST['access_login']);
    unset($_POST['access_password']);
    unset($_POST['Submit']);
  }

}

else {

  // check if password cookie is set
  if (!isset($_COOKIE['verify'])) {
    showLoginPasswordProtect("");
  }

  // check if cookie is good
  $found = false;
  foreach($LOGIN_INFORMATION as $key=>$val) {
    $lp = (USE_USERNAME ? $key : '') .'%'.$val;
    if ($_COOKIE['verify'] == md5($lp)) {
      $found = true;
      // prolong timeout
      if (TIMEOUT_CHECK_ACTIVITY) {
        setcookie("verify", md5($lp), $timeout, '/');
      }
      break;
    }
  }
  if (!$found) {
    showLoginPasswordProtect("");
  }

}

?>

