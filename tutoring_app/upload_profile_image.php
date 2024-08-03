<?php
require "connect.php";

header('Content-Type: application/json');

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_FILES['profile_images']) && isset($_POST['username'])) {
        $username = $_POST['username'];
        $imageName = $_FILES['profile_images']['name'];
        $imageTmpName = $_FILES['profile_images']['tmp_name'];
        $uploadDir = 'uploads/';

      
        $newImageName = uniqid() . '-' . $imageName;

        if (move_uploaded_file($imageTmpName, $uploadDir . $newImageName)) {
           
            $stmt = $con->prepare("UPDATE tutors SET profile_images = ? WHERE name = ?");
            $stmt->bind_param("ss", $newImageName, $username);
            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'image_url' => $newImageName]);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Failed to update database']);
            }
            $stmt->close();
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Failed to upload image']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid request']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}

$con->close();
?>
