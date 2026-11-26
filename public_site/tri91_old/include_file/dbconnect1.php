<?php

$servername = "45.91.133.62";
$username = "root";
$password = "MySQLtripitaka91";
$dbname = "correction";

// Create connection
$conn1 = new mysqli($servername, $username, $password, $dbname);
mysqli_set_charset($conn1,"utf8");

// Check connection
 if ($conn1->connect_error) {
     die("Connection failed: " . $conn1->connect_error);
} 
//echo "Connected successfully";
?>