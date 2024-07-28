<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tutoring_app";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

$sql = "SELECT * FROM port_messages";
$result = $conn->query($sql);

$messages = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $messages[] = $row;
    }
    echo json_encode(["status" => "success", "messages" => $messages]);
} else {
    echo json_encode(["status" => "success", "messages" => []]);
}

$conn->close();
?>
