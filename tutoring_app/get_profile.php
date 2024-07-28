<?php

$servername = "localhost"; 
$username = "root"; 
$password = ""; 
$dbname = "tutoring_app"; 


$conn = new mysqli($servername, $username, $password, $dbname);


if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}


$sql = "SELECT name, subject, email, address, profile_images FROM tutors WHERE tutor_id = 1"; 

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    
    $row = $result->fetch_assoc();
    
    header('Content-Type: application/json');
    echo json_encode($row);
} else {
    echo "0 results";
}

$conn->close();
?>
