<?php
header("Content-Type: application/json; charset=UTF-8");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tutoring_app";

$conn = new mysqli($servername, $username, $password, $dbname);


if ($conn->connect_error) {
    die(json_encode(array("status" => "error", "message" => "Connection failed: " . $conn->connect_error)));
}


$category = isset($_GET['category']) ? $conn->real_escape_string($_GET['category']) : "";


$sql = "SELECT id, name, description FROM subjects WHERE category = '$category'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $subjects = array();
    while ($row = $result->fetch_assoc()) {
        $subjects[] = array(
            "id" => $row["id"],
            "name" => $row["name"],
            "description" => $row["description"],
            "topics" => array() 
        );
    }
    echo json_encode(array("status" => "success", "subjects" => $subjects));
} else {
    echo json_encode(array("status" => "error", "message" => "No subjects found"));
}

$conn->close();
?>
