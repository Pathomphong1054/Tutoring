<?php
header('Content-Type: application/json; charset=utf-8');
ini_set('display_errors', 0);
error_reporting(E_ERROR | E_PARSE);

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tutoring_db";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['username']) && isset($_FILES['resumes_images'])) {
        $username = $_POST['username'];
        $resumeFile = $_FILES['resumes_images'];

        $target_dir = "uploads/";
        $target_file = $target_dir . basename($resumeFile["name"]);
        $uploadOk = 1;
        $fileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

      
        if ($resumeFile["size"] > 10000000) {
            echo json_encode(['status' => 'error', 'message' => 'Sorry, your file is too large.']);
            $uploadOk = 0;
        }

       
        $allowedTypes = ['jpg', 'png', 'jpeg', 'gif'];
        if (!in_array($fileType, $allowedTypes)) {
            echo json_encode(['status' => 'error', 'message' => 'Sorry, only JPG, JPEG, PNG & GIF files are allowed.']);
            $uploadOk = 0;
        }

        
        if ($uploadOk == 0) {
            echo json_encode(['status' => 'error', 'message' => 'Sorry, your file was not uploaded.']);
        } else {
            
            if (move_uploaded_file($resumeFile["tmp_name"], $target_file)) {
                
                $stmt = $conn->prepare("UPDATE tutors SET resumes_images = ? WHERE name = ?");
                $stmt->bind_param("ss", $target_file, $username);
                if ($stmt->execute()) {
                    echo json_encode(['status' => 'success', 'resume_url' => $target_file]);
                } else {
                    echo json_encode(['status' => 'error', 'message' => 'Error updating database.']);
                }
                $stmt->close();
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Sorry, there was an error uploading your file.']);
            }
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid parameters.']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method.']);
}

$conn->close();
?>
