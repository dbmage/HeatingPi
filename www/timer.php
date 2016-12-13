<html>
<head>
<meta http-equiv="Content-type" content="text/html;charset=UTF-8">
<link rel="stylesheet" type="text/css" href="dad.css">
<style type="text/css">
h1
{
color: white;
}
</style>
</head>
<body>
<h1><a href="../">Home</a></h1>
<table class="dad">
<tr style="text-align:center">
<td></td>
<td>08:00</td>
<td>09:00</td>
<td>10:00</td>
<td>11:00</td>
<td>12:00</td>
<td>13:00</td>
<td>14:00</td>
<td>15:00</td>
<td>16:00</td>
</tr>
<tr>
<td>Monday</td>
<td style="text-align:center"><input type="checkbox" name="heat[]" value="a"></td>
<td style="text-align:center"><input type="checkbox" name="heat[]" value="b"></td>
<td style="text-align:center"><input type="checkbox" name="heat[]" value="c"></td>
<td style="text-align:center"><input type="checkbox" name="heat[]" value="m11"></td>
<td style="text-align:center"><input type="checkbox" name="heat[]" value="m12"></td>
<td style="text-align:center"><input type="checkbox" name="heat[]" value="m13"></td>
<td style="text-align:center"><input type="checkbox" name="heat[]" value="m14"></td>
<td style="text-align:center"><input type="checkbox" name="heat[]" value="m15"></td>
<td style="text-align:center"><input type="checkbox" name="heat[]" value="m16"></td>
</tr>
<tr>
<td>Tuesday</td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
</tr>
<tr>
<td>Wednesday</td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
</tr>
<tr>
<td>Thursday</td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
</tr>
<tr>
<td>Friday</td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
</tr>
<tr>
<td>Saturday</td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
</tr>
<tr>
<td>Sunday</td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
<td style="text-align:center"><input type="checkbox"></td>
</tr>
</table>
<form method="POST" action=''>
<input type=SUBMIT name="Submit" value="heat">
</form>
<?php

$heat = $_POST['heat'];
  if(empty($heat))
  {
    echo("<h1>Heating set to always off.</h1>");
  }
  else
  {
    $N = count($heat);
    echo("You selected $N door(s): ");
    for($i=0; $i < $N; $i++)
    {
      echo htmlspecialchars($heat[$i] ). " ";
    }
  }
?>
</body>
</html>

