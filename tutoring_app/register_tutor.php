<?php
require "connect.php";

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$name = $_POST['name'];
$password = $_POST['password'];
$email = $_POST['email'];
$category = $_POST['category'];
$subject = $_POST['subject'];
$topic = $_POST['topic'];
$address = $_POST['address'];
$encrypted_pwd = password_hash($password, PASSWORD_BCRYPT);


function handleFileUpload($file, $uploadDir, $allowedTypes) {
    $fileName = basename($file["name"]);
    $targetFilePath = $uploadDir . $fileName;
    $fileType = pathinfo($targetFilePath, PATHINFO_EXTENSION);
    
    if (in_array($fileType, $allowedTypes)) {
        if (move_uploaded_file($file["tmp_name"], $targetFilePath)) {
            return $fileName;
        }
    }
    return false;
}


$uploadDir = "uploads/";
$allowedTypes = array('jpg', 'png', 'jpeg');


$profileImage = isset($_FILES['profile_image']) ? handleFileUpload($_FILES['profile_image'], $uploadDir, $allowedTypes) : null;


$resumeFile = isset($_FILES['resume']) ? handleFileUpload($_FILES['resume'], $uploadDir, $allowedTypes) : null;

$stmt = $con->prepare("SELECT * FROM tutors WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();
$count = $result->num_rows;

if ($count > 0) {
    echo json_encode(['status' => 'error', 'message' => 'Email already exists']);
} else {
    $stmt = $con->prepare("INSERT INTO tutors(name, password, email, category, subject, topic, address, profile_images, resumes_images) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("sssssssss", $name, $encrypted_pwd, $email, $category, $subject, $topic, $address, $profileImage, $resumeFile);
    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Registration succeeded']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Registration failed']);
    }
}

$stmt->close();
$con->close();
?>
