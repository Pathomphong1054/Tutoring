<?php
header('Content-Type: application/json');
require "connect.php";

// Check if the request is a POST request
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Check if a file was uploaded
    if (isset($_FILES['profile_images']) && $_FILES['profile_images']['error'] == UPLOAD_ERR_OK) {
        $uploadDir = './uploads/profile_images/'; // Directory where the file will be uploaded
        $uploadedFile = $_FILES['profile_image'];
        $uploadedFileName = basename($uploadedFile['name']);
        $targetFilePath = $uploadDir . $uploadedFileName;

        // Move uploaded file to target location
        if (move_uploaded_file($uploadedFile['tmp_name'], $targetFilePath)) {
            $imageUrl = 'http://192.168.207.193/tutoring_app/uploads/profile_images/' . $uploadedFileName; // Replace with your domain and upload directory
            $response = array('status' => 'success', 'image_url' => $imageUrl);
            echo json_encode($response);
        } else {
            $response = array('status' => 'error', 'message' => 'Failed to move uploaded file');
            echo json_encode($response);
        }
    } else {
        $response = array('status' => 'error', 'message' => 'No file uploaded or file upload error occurred');
        echo json_encode($response);
    }
} else {
    $response = array('status' => 'error', 'message' => 'Invalid request method');
    echo json_encode($response);
}
?>
