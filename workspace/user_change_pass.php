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
    $email = isset($_POST["email"]) ? $_POST["email"] : '';
    $oldPassword = isset($_POST["old_password"]) ? $_POST["old_password"] : '';
    $newPassword = isset($_POST["new_password"]) ? $_POST["new_password"] : '';

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
        // ตรวจสอบรหัสผ่านเดิม
        if (password_verify($oldPassword, $user['password'])) {
            // รหัสผ่านเก่าถูกต้อง
            // อัพเดทรหัสผ่านใหม่ในฐานข้อมูล
            $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
            $updateSql = "UPDATE users SET password = :password WHERE email = :email OR username = :email";
            $updateStmt = $conn->prepare($updateSql);
            $updateStmt->bindParam(':password', $hashedPassword);
            $updateStmt->bindParam(':email', $email);
            $updateStmt->execute();

            echo json_encode([
                'success' => true,
                'message' => 'รีเซ็ตรหัสผ่านสำเร็จ',                
            ], JSON_UNESCAPED_UNICODE);
        } else {
            // ไม่พบผู้ใช้หรือรหัสผ่านเก่าไม่ถูกต้อง
            echo json_encode([
                'success' => false,
                'message' => 'รหัสผ่านเดิมไม่ถูกต้อง'
            ], JSON_UNESCAPED_UNICODE);
        }
    } else {
        // ไม่พบผู้ใช้หรือรหัสผ่านเก่าไม่ถูกต้อง
        echo json_encode([
            'success' => false,
            'message' => 'อีเมล์หรือรหัสผ่านเก่าไม่ถูกต้อง'
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
