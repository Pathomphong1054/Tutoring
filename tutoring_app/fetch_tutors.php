<?php
require "connect.php";

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$stmt = $con->prepare("SELECT name, category, subject, topic, email, address, profile_images FROM tutors");
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
