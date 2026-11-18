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
    $username = isset($_POST["username"]) ? $_POST["username"] : '';

    // ตรวจสอบความถูกต้องของ Token ก่อนดำเนินการต่อ
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
    
    $sql = "SELECT COUNT(*) as total
    FROM log_edit
    WHERE tripitaka91_user = :username";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':username', $username, PDO::PARAM_STR);
    $stmt->execute();

    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    $totalLogs = $result['total']; // รับค่ารวมจำนวนรายการ

    $sql = "UPDATE users SET counter_wordcorrec = :totalLogs WHERE username = :username";
    $stmt = $conn->prepare($sql);    
    $stmt->bindParam(':totalLogs', $totalLogs, PDO::PARAM_INT);    
    $stmt->bindParam(':username', $username, PDO::PARAM_STR);
    $stmt->execute();
    
    echo json_encode([
        'success' => true,
        'message' => 'อัปเดตค่า counter_wordcorrec เรียบร้อยแล้ว',
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    // จัดการข้อผิดพลาดที่เกิดขึ้นจากการเชื่อมต่อหรือการประมวลผล SQL
    echo json_encode([
        'success' => false,
        'message' => 'เกิดข้อผิดพลาด: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
