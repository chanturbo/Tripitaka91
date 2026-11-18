<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

// ฟังก์ชันสำหรับบันทึก log ลงฐานข้อมูล
function logUserActivity($conn, $userEmail, $activity) {
    $sql = "INSERT INTO user_activity_log (user_email, activity) VALUES (:user_email, :activity)";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':user_email', $userEmail);
    $stmt->bindParam(':activity', $activity);
    $stmt->execute();
}

try {
    $webconfig = new WebsiteConfig();
    $db = new Database(); // สร้างอ็อบเจกต์ Database
    $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO

    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $email = isset($_POST["email"]) ? $_POST["email"] : '';
    $level = isset($_POST["level"]) ? (int)$_POST["level"] : 0; // รับค่า level และแปลงเป็น int
    $emailProcess = isset($_POST["email_process"]) ? $_POST["email_process"] : '';


    // ตรวจสอบความถูกต้องของ Token ก่อนดำเนินการต่อ
    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    // ตรวจสอบชื่อผู้ใช้และรหัสผ่านในฐานข้อมูล
    $sql = "SELECT * FROM users WHERE email = :email OR username = :email";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':email', $email);
    $stmt->execute();
    
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        // พบผู้ใช้
        // อัพเดทสถานะของผู้ใช้ตามค่าที่รับเข้ามา
        $updateSql = "UPDATE users SET permission_voice = :level WHERE email = :email OR username = :email";
        $updateStmt = $conn->prepare($updateSql);        
        $updateStmt->bindParam(':email', $email);
        $updateStmt->bindParam(':level', $level, PDO::PARAM_INT);
        $updateStmt->execute();
    
        logUserActivity($conn, $emailProcess, $email . " User Permission Voice updated to $level successfully.");

        echo json_encode([
            'success' => true,
            'message' => 'การเป็นผู้มีสิทธิ์ยืนยันเสียงอ่านสำเร็จ',
            'user' => $user
        ], JSON_UNESCAPED_UNICODE);
    } else {
        // ไม่พบผู้ใช้
        echo json_encode([
            'success' => false,
            'message' => 'ไม่พบผู้ใช้หรือข้อมูลไม่ถูกต้อง'
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
