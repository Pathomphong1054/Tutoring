<?php
header('Content-Type: application/json');

// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tutoring_app";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
}

$sql = "SELECT title, message FROM notifications WHERE user = 'tutor1'"; // Adjust your query as needed
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $notifications = [];
    while($row = $result->fetch_assoc()) {
        $notifications[] = $row;
    }
    echo json_encode($notifications);
} else {
    echo json_encode([]);
}

$conn->close();
?>
