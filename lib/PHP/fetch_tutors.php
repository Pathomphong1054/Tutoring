<?php
require "connect.php";

// Check if connected to the database
if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

// Fetch tutors data from database
$stmt = $con->prepare("SELECT name, subject, profile_images FROM tutors");
$stmt->execute();
$result = $stmt->get_result();
$tutors = [];

while ($row = $result->fetch_assoc()) {
    $tutors[] = $row;
}

echo json_encode(['status' => 'success', 'tutors' => $tutors]);

$stmt->close();
$con->close();
?>
