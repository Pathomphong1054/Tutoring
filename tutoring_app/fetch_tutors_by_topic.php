<?php
require "connect.php";

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$topic = $_GET['topic'];
$stmt = $con->prepare("SELECT name, category, subject, topic, profile_images FROM tutors WHERE topic = ?");
$stmt->bind_param("s", $topic);
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
