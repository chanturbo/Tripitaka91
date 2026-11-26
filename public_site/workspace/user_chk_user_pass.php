<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {    
    $webconfig = new WebsiteConfig();
    $db = new Database(); // สร้างอ็อบเจกต์ Database
    $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO
    
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $identifier = isset($_POST["identifier"]) ? $_POST["identifier"] : '';
    
    // ตรวจสอบความถูกต้องของ Token ก่อนดำเนินการต่อ
    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    // ตรวจสอบว่า identifier เป็นชื่อผู้ใช้งาน (Username) หรือ อีเมล์ (Email)
    $identifierType = filter_var($identifier, FILTER_VALIDATE_EMAIL) ? 'email' : 'username';

    // ตรวจสอบชื่อผู้ใช้งานหรืออีเมล์ในฐานข้อมูล
    $sql = "SELECT username, email FROM users WHERE $identifierType = :identifier";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':identifier', $identifier);
    $stmt->execute();
    
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        // พบผู้ใช้ที่ตรงกับข้อมูลที่รับมา
        echo json_encode([
            'success' => true,
            'message' => 'พบข้อมูล',
            'user' => $user,
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    } else {
        // ไม่พบผู้ใช้
        echo json_encode([
            'success' => false,
            'message' => 'ไม่พบชื่อผู้ใช้งานหรืออีเมล์ในระบบ'
        ], JSON_UNESCAPED_UNICODE);
    }
    
} catch (Exception $e) {
    // จัดการข้อผิดพลาดที่เกิดขึ้นจากการเชื่อมต่อหรือการประมวลผล SQL
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถติดต่อฐานข้อมูลได้: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
