<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

require "connect.php";

header('Content-Type: application/json');

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$username = $_POST['username'];
$new_name = $_POST['name'];
$category = $_POST['category'];
$subject = $_POST['subject'];
$topic = $_POST['topic'];
$email = $_POST['email'];
$address = $_POST['address'];

$profileImage = null;

if (!empty($_FILES['profile_images']['name'])) {
    $targetDir = "uploads/";
    $fileName = basename($_FILES['profile_images']['name']);
    $targetFilePath = $targetDir . $fileName;
    $fileType = pathinfo($targetFilePath, PATHINFO_EXTENSION);

    $allowTypes = array('jpg', 'png', 'jpeg', 'gif');
    if (in_array($fileType, $allowTypes)) {
        if (move_uploaded_file($_FILES['profile_images']['tmp_name'], $targetFilePath)) {
            $profileImage = $fileName;
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Failed to upload profile image']);
            exit();
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid file type']);
        exit();
    }
}

if ($profileImage) {
    $stmt = $con->prepare("UPDATE tutors SET name=?, category=?, subject=?, topic=?, email=?, address=?, profile_images=? WHERE name=?");
    $stmt->bind_param("ssssssss", $new_name, $category, $subject, $topic, $email, $address, $profileImage, $username);
} else {
    $stmt = $con->prepare("UPDATE tutors SET name=?, category=?, subject=?, topic=?, email=?, address=? WHERE name=?");
    $stmt->bind_param("sssssss", $new_name, $category, $subject, $topic, $email, $address, $username);
}

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Profile updated successfully', 'image_url' => $profileImage]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update profile']);
}

$stmt->close();
$con->close();
?>
