<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tutoring_app";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Insert sample user data
$sql = "INSERT INTO users (username, password, role, email, name, category, subject, topic) VALUES
('student1', 'password123', 'student', 'student1@example.com', 'Student One', '', '', ''),
('tutor1', 'password123', 'tutor', 'tutor1@example.com', 'Tutor One', 'Computer Science', 'Programming', 'C++')";

if ($conn->query($sql) === TRUE) {
    echo "Sample users created successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
