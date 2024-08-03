<?php
require "connect.php";

header('Content-Type: application/json');

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$username = $_GET['username'];
$role = $_GET['role'];

if ($role == 'tutor') {
    $stmt = $con->prepare("SELECT * FROM tutors WHERE name = ?");
} else {
    $stmt = $con->prepare("SELECT * FROM students WHERE name = ?");
}

$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();
if ($result->num_rows > 0) {
    $profile = $result->fetch_assoc();
    echo json_encode([
        'status' => 'success',
        'name' => $profile['name'],
        'category' => isset($profile['category']) ? $profile['category'] : null,
        'subject' => isset($profile['subject']) ? $profile['subject'] : null,
        'topic' => isset($profile['topic']) ? $profile['topic'] : null,
        'email' => $profile['email'],
        'address' => $profile['address'],
        'profile_image' => $profile['profile_images'],
    ]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'User not found']);
}
$stmt->close();
$con->close();
?>
