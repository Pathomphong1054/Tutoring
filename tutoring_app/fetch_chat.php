<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tutoring_app";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
}

$sender = $_GET['sender'];
$recipient = $_GET['recipient'];

$sql = "SELECT * FROM messages WHERE (sender='$sender' AND recipient='$recipient') OR (sender='$recipient' AND recipient='$sender') ORDER BY created_at ASC";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $messages = [];
    while($row = $result->fetch_assoc()) {
        $messages[] = $row;
    }
    echo json_encode($messages);
} else {
    echo json_encode([]);
}

$conn->close();
?>
