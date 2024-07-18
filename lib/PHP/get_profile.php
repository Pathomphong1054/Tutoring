<?php
$userId = 1; // Use the actual user ID
$conn = new mysqli("localhost", "username", "password", "database");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT name, address, profile_image FROM students WHERE id=$userId";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode([
        'name' => $row['name'],
        'address' => $row['address'],
        'profile_images' => $row['profile_images']
    ]);
} else {
    echo json_encode(['error' => 'No profile found']);
}
$conn->close();
?>
