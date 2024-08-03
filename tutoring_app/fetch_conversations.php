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

$user = $_GET['user'];

// Fetch distinct conversations and include the full names
$sql = "SELECT DISTINCT users.name AS conversation_with, messages.recipient AS recipient_username, users.profile_image AS recipient_image, messages.message AS last_message, messages.created_at AS timestamp
        FROM messages 
        JOIN users ON users.username = messages.recipient 
        WHERE sender='$user'
        UNION 
        SELECT DISTINCT users.name AS conversation_with, messages.sender AS sender_username, users.profile_image AS sender_image, messages.message AS last_message, messages.created_at AS timestamp
        FROM messages 
        JOIN users ON users.username = messages.sender 
        WHERE recipient='$user'";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $conversations = [];
    while($row = $result->fetch_assoc()) {
        $conversations[] = $row;
    }
    echo json_encode($conversations);
} else {
    echo json_encode([]);
}

$conn->close();
?>
