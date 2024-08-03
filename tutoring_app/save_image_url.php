<?php
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $type = $_POST['type'];
    $image_url = $_POST['image_url'];

   
    $servername = "localhost";
    $username = "root";
    $password = "";
    $dbname = "tutoring_app";

    $conn = new mysqli($servername, $username, $password, $dbname);

    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    $sql = "UPDATE tutors SET {$type}_image = '$image_url' WHERE id = 1"; 

    if ($conn->query($sql) === TRUE) {
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error']);
    }

    $conn->close();
}
?>
