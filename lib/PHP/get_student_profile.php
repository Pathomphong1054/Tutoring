<?php
// เชื่อมต่อฐานข้อมูล
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tutoring_app";

try {
    // เชื่อมต่อกับ MySQL โดยใช้ PDO
    $pdo = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // คิวรี่ข้อมูลจากตาราง student_profile โดยใช้ id = 1 (สามารถเปลี่ยนเป็นเงื่อนไขที่ต้องการ)
    $stmt = $pdo->prepare("SELECT * FROM students WHERE id = 1"); // แก้ไขตามต้องการ
    $stmt->execute();

    // ดึงข้อมูลเป็น associative array
    $profile = $stmt->fetch(PDO::FETCH_ASSOC);

    // ตรวจสอบว่าพบข้อมูลหรือไม่
    if ($profile) {
        echo json_encode($profile); // แปลงเป็น JSON และส่งกลับไปยังแอพพลิเคชัน Flutter
    } else {
        echo json_encode(['error' => 'Profile not found']); // กรณีไม่พบข้อมูล
    }
} catch (PDOException $e) {
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]); // กรณีเกิดข้อผิดพลาดในการเชื่อมต่อฐานข้อมูล
}
?>
