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
    $words = isset($_POST["words"]) ? $_POST["words"] : '';
    $words_speak = isset($_POST["words_speak"]) ? $_POST["words_speak"] : '';

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }
    
    if (($words == '') || ($words_speak == '') || ($username == '')) { // แก้ไขเงื่อนไขการตรวจสอบข้อมูลที่จะบันทึก
        echo json_encode([
            'success' => false,
            'message' => 'ไม่มีข้อมูลที่จะบันทึก'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        die();
    }

    $conn->beginTransaction(); // เริ่ม Transaction

    // ตรวจสอบว่าคำนี้มีการบันทึกแล้วหรือไม่
    $check_sql = "SELECT * FROM log_speak WHERE words = ?";
    $check_stmt = $conn->prepare($check_sql);
    $check_stmt->execute([$words]);
    $existing_data = $check_stmt->fetch(PDO::FETCH_ASSOC);

    if ($existing_data) { // ถ้ามีข้อมูลในฐานข้อมูลแล้ว
        // อัปเดตเฉพาะฟิลด์ words_speak
        $update_sql = "UPDATE log_speak SET words_speak = :words_speak WHERE words = :words";
        $update_stmt = $conn->prepare($update_sql);
        $update_stmt->bindValue(':words_speak', $words_speak, PDO::PARAM_STR);
        $update_stmt->bindValue(':words', $words, PDO::PARAM_STR);

        $update_stmt->execute(); // ดำเนินการอัปเดต

        // ตรวจสอบว่าการ update สำเร็จ
        if ($update_stmt) {
            $conn->commit(); // ยืนยัน Transaction
            echo json_encode([
                'success' => true,
                'message' => "อัปเดต $words เรียบร้อยแล้ว"
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        } else {
            $conn->rollBack(); // ยกเลิก Transaction หากไม่สามารถอัปเดตได้
            echo json_encode([
                'success' => false,
                'message' => 'ไม่สามารถอัปเดตข้อมูลได้'
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        }
    } else {
        // หากไม่พบคำในฐานข้อมูล
        echo json_encode([
            'success' => false,
            'message' => "ไม่พบคำว่า $words ในฐานข้อมูล"
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }

} catch (Exception $e) {
    // ยกเลิก Transaction และจัดการข้อผิดพลาด
    $conn->rollBack();
    echo json_encode([
        'success' => false,
        'message' => 'เกิดข้อผิดพลาด: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
