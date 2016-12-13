<?php
shell_exec('mv index.php readme.php; mv index1.php index.php; rm go.php');
header('Location: index.php');
?>
