<?php
require "connect.php";
// Configuration
$targetDir = "uploads/profile_images/"; // โฟลเดอร์ที่จะบันทึกไฟล์รูปภาพโปรไฟล์
$targetFile = $targetDir . basename($_FILES["profile_images"]["name"]);
$uploadOk = 1;
$imageFileType = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));

// Check if file already exists
if (file_exists($targetFile)) {
    echo json_encode(array("error" => "File already exists."));
    $uploadOk = 0;
}

// Check file size
if ($_FILES["profile_images"]["size"] > 5000000) { // 5 MB
    echo json_encode(array("error" => "File size is too large."));
    $uploadOk = 0;
}

// Allow certain file formats (JPEG, JPG, PNG)
if($imageFileType != "jpg" && $imageFileType != "jpeg" && $imageFileType != "png") {
    echo json_encode(array("error" => "Only JPEG, JPG, PNG files are allowed."));
    $uploadOk = 0;
}

// Check if $uploadOk is set to 0 by an error
if ($uploadOk == 0) {
    echo json_encode(array("error" => "File was not uploaded."));
// if everything is ok, try to upload file
} else {
    if (move_uploaded_file($_FILES["profile_images"]["tmp_name"], $targetFile)) {
        echo json_encode(array("image_url" => $targetFile));
    } else {
        echo json_encode(array("error" => "Error uploading file."));
    }
}
?>
