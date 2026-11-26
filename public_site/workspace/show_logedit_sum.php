<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {    
    $webconfig = new WebsiteConfig();
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : '';

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    // เพิ่มเงื่อนไขเพื่อตรวจสอบว่า username ไม่เป็นค่าว่าง
    if (empty($username)) {
        echo json_encode([
            'success' => false,
            'message' => 'กรุณากรอกชื่อผู้ใช้'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า username เป็นค่าว่าง
    }
        
    $db = new Database(); // สร้างอ็อบเจกต์ Database
    $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO
    
    $sql = "SELECT COUNT(*) as total
            FROM log_edit
            WHERE tripitaka91_user = :username";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':username', $username, PDO::PARAM_STR);
    $stmt->execute();

    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    $totalLogs = $result['total']; // รับค่ารวมจำนวนรายการ

    echo json_encode([
        'success' => true,
        'total_logs' => $totalLogs // ส่งเฉพาะค่ารวมกลับไป
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    // จัดการข้อผิดพลาดที่เกิดขึ้นจากการเชื่อมต่อหรือการประมวลผล SQL
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
