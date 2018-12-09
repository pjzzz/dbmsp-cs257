<?php
$db_server   = "localhost";
$db = "foods";
$db_user = "fuser";
$db_pass = "fpass";
// Create connection
$conn = new mysqli($db_server, $db_user, $db_pass);
// Check connection
if ($conn->connect_error) {
   die("Connection failed: " . $conn->connect_error);
}
$query = "use $db";
mysqli_query($conn,$query);
?>