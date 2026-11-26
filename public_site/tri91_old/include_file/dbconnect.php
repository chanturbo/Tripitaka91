<?php

$servername = "45.91.133.62";
$username = "root";
$password = "MySQLtripitaka91";
$dbname = "tripitaka91_dbnew";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
mysqli_set_charset($conn,"utf8");

// Check connection
 if ($conn->connect_error) {
     die("Connection failed: " . $conn->connect_error);
} 
//echo "Connected successfully";
?>