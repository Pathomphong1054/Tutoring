<?php

if (isset($_SERVER['HTTP_ORIGIN'])) {
    header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
    header('Access-Control-Allow-Credentials: true');
    header('Access-Control-Max-Age: 86400');    
}


if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))
        header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']))
        header("Access-Control-Allow-Headers: {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");

    exit(0);
}


if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_FILES['image']['name'])) {
    $user_id = $_POST['user_id'];  

    $target_dir = "uploads/"; 
    $target_file = $target_dir . basename($_FILES["image"]["name"]);
    $uploadOk = 1;
    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

    
    $check = getimagesize($_FILES["image"]["tmp_name"]);
    if ($check !== false) {
        $uploadOk = 1;
    } else {
        echo json_encode(array('error' => 'File is not an image.'));
        $uploadOk = 0;
    }

    
    if ($_FILES["image"]["size"] > 500000) { 
        echo json_encode(array('error' => 'File is too large.'));
        $uploadOk = 0;
    }

   
    if ($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg"
        && $imageFileType != "gif") {
        echo json_encode(array('error' => 'Only JPG, JPEG, PNG & GIF files are allowed.'));
        $uploadOk = 0;
    }

    
    if ($uploadOk == 0) {
        echo json_encode(array('error' => 'Failed to upload image.'));
    } else {
        if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_file)) {
            echo json_encode(array('profile_images' => $target_file));
        } else {
            echo json_encode(array('error' => 'Error uploading file.'));
        }
    }
} else {
    echo json_encode(array('error' => 'No file uploaded.'));
}
?>
