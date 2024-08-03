<?php
require "connect.php";

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$name = $_POST['name'];
$password = $_POST['password'];
$email = $_POST['email'];
$address = $_POST['address'];
$encrypted_pwd = password_hash($password, PASSWORD_BCRYPT);


function handleFileUpload($file, $uploadDir, $allowedTypes) {
    $fileName = basename($file["name"]);
    $targetFilePath = $uploadDir . $fileName;
    $fileType = pathinfo($targetFilePath, PATHINFO_EXTENSION);
    
    if(in_array(strtolower($fileType), $allowedTypes)) {
        if(move_uploaded_file($file["tmp_name"], $targetFilePath)) {
            return $fileName;
        }
    }
    return false;
}


$uploadDir = "uploads/profile_images/";
$allowedTypes = array('jpg', 'png', 'jpeg', 'gif');


$profileImage = isset($_FILES['profile_image']) ? handleFileUpload($_FILES['profile_image'], $uploadDir, $allowedTypes) : null;

$stmt = $con->prepare("SELECT * FROM students WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();
$count = $result->num_rows;

if ($count > 0) {
    echo json_encode(['status' => 'error', 'message' => 'Email already exists']);
} else {
    $stmt = $con->prepare("INSERT INTO students(name, password, email, address, profile_images) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("sssss", $name, $encrypted_pwd, $email, $address, $profileImage);
    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Registration succeeded']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Registration failed']);
    }
}

$stmt->close();
$con->close();
?>
