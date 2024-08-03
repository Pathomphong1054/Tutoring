<?php
require "connect.php";

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$subject = $_GET['subject'];

$stmt = $con->prepare("SELECT name, subject,category, profile_images FROM tutors WHERE subject = ?");
$stmt->bind_param("s", $subject);
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
