<body style="background-color: black; color: white;">
<h2>Main page for controlling heating (and hot water if applicable)</h2>
    <img src="readme1.png">
    <hr>
<h2>Pages for managing the schedule</h2>
    <img style="width: 49%;" src="readme2.png"><img style="width: 49%;" src="readme2b.png">
    <hr>
<h2>Admin page for other maintenance</h2>
    <img style="width: 400px; float: left;" src="readme3.png"><br>
    <h3 style="color:red;">Pi management</h3>
    <h3 style="color:yellow;">MySQL WebUI</h3>
    <h3 style="color:green;">Pi GPIO pin states</h3>
    <h3 style="color:blue;">Script Log Files</h3>
    <h3 style="color:purple;">Request the correct time</h3>
    <h3 style="color:pink;">Show current queue</h3>
<button style="float: right; width: 100px; height: 60px; font-size: 25px;" onclick="relocate()">Got it!</button>
</body>
<script>
function relocate() {
    window.alert("To revisit this page go to " + window.location.href + "readme.php");
    window.location.href="go.php";
}
</script>