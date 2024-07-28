<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tutoring_app";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Get the posted data
$postdata = file_get_contents("php://input");

if (isset($postdata) && !empty($postdata)) {
    $request = json_decode($postdata);

    // Sanitize
    $message = mysqli_real_escape_string($conn, trim($request->message));
    $startDate = mysqli_real_escape_string($conn, trim($request->startDate));
    $endDate = mysqli_real_escape_string($conn, trim($request->endDate));
    $startTime = mysqli_real_escape_string($conn, trim($request->startTime));
    $endTime = mysqli_real_escape_string($conn, trim($request->endTime));
    $userName = mysqli_real_escape_string($conn, trim($request->userName));
    $profileImageUrl = mysqli_real_escape_string($conn, trim($request->profileImageUrl));
    $subject = mysqli_real_escape_string($conn, trim($request->subject));

    // Store message
    $sql = "INSERT INTO port_messages (message, startDate, endDate, startTime, endTime, userName, profileImageUrl, subject) VALUES ('$message', '$startDate', '$endDate', '$startTime', '$endTime', '$userName', '$profileImageUrl', '$subject')";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success", "message" => "Message posted successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error: " . $sql . "<br>" . $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "No data provided"]);
}

$conn->close();
?>
