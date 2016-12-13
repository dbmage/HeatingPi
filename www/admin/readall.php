<?php
$readall = shell_exec('gpio readall');

echo "<pre> $readall </pre>";

$load = shell_exec('echo $(date +"%T")');

echo "<a>Loaded at " .$load."</a>";

?>
<style type="text/css">
pre
{
font-size: 20px;
}
</style>
