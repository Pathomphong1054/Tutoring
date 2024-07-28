<?php
require "connect.php";

header('Content-Type: application/json');

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_POST['username']) && isset($_POST['name']) && isset($_POST['email']) && isset($_POST['address'])) {
        $username = $_POST['username'];
        $name = $_POST['name'];
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
            $stmt = $con->prepare("UPDATE students SET name=?, email=?, address=?, profile_images=? WHERE name=?");
            $stmt->bind_param("sssss", $name, $email, $address, $profileImage, $username);
        } else {
            $stmt = $con->prepare("UPDATE students SET name=?, email=?, address=? WHERE name=?");
            $stmt->bind_param("ssss", $name, $email, $address, $username);
        }

        if ($stmt->execute()) {
            $response = ['status' => 'success', 'message' => 'Profile updated successfully'];
            if ($profileImage) {
                $response['image_url'] = $profileImage;
            }
            echo json_encode($response);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Failed to update profile']);
        }

        $stmt->close();
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid request']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}

$con->close();
?>
