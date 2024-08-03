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
    die(json_encode(array('status' => 'error', 'message' => 'Database connection failed')));
}

if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
}

$data = json_decode(file_get_contents('php://input'), true);

$student = $data['student'];
$tutor = $data['tutor'];
$date = $data['date'];
$startTime = $data['startTime'];
$endTime = $data['endTime'];
$rate = $data['rate'];

$sql = "INSERT INTO tutoring_sessions (student, tutor, date, start_time, end_time, rate) VALUES ('$student', '$tutor', '$date', '$startTime', '$endTime', '$rate')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success', 'message' => 'Session scheduled successfully']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Error: ' . $sql . '<br>' . $conn->error]);
}

$conn->close();
?>
