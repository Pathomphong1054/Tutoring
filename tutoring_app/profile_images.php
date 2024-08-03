<?php
require "connect.php";

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$username = $_GET['username'];
$stmt = $con->prepare("SELECT * FROM students WHERE name = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();
if ($result->num_rows > 0) {
    $profile = $result->fetch_assoc();
    echo json_encode([
        'status' => 'success',
        'name' => $profile['name'],
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
