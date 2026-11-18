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
    $user_name = isset($_POST["user"]) ? $_POST["user"] : '';    
    $voice_choice = isset($_POST["voice_choice"]) ? $_POST["voice_choice"] : '';


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
    $sql = "SELECT * FROM users WHERE  username = :user_name";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':user_name', $user_name);
    $stmt->execute();
    
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        // พบผู้ใช้
        // อัพเดทสถานะของผู้ใช้ตามค่าที่รับเข้ามา
        $updateSql = "UPDATE users SET voice_choice = :voice_choice WHERE username = :user_name";
        $updateStmt = $conn->prepare($updateSql);        
        $updateStmt->bindParam(':user_name', $user_name);
        $updateStmt->bindParam(':voice_choice', $voice_choice);
        $updateStmt->execute();

        echo json_encode([
            'success' => true,
            'message' => 'กำหนดเสียงอ่านเรียบร้อยแล้ว',
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
