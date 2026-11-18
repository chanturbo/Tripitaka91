<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {    
    $webconfig = new WebsiteConfig();
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : '';
    $searchText = isset($_POST["words"]) ? $_POST["words"] : '';  // รับค่าการค้นหาจากโพสต์

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    // ตรวจสอบว่า username และ searchText ไม่เป็นค่าว่าง
    if (empty($username) || empty($searchText)) {
        echo json_encode([
            'success' => false,
            'message' => 'กรุณาเลือกคำที่ต้องการลบ'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้าไม่มี username หรือ searchText
    }
        
    $db = new Database(); // สร้างอ็อบเจกต์ Database
    $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO

    // เริ่มต้น Transaction
    $conn->beginTransaction();

    // เริ่มต้นการเตรียม SQL Query สำหรับการลบข้อมูลจาก log_speak_confirm
    $delete_confirm_sql = "DELETE FROM log_speak_confirm WHERE tripitaka91_user = :username AND words = :searchText";
    $delete_confirm_stmt = $conn->prepare($delete_confirm_sql);
    $delete_confirm_stmt->bindValue(':username', $username, PDO::PARAM_STR);
    $delete_confirm_stmt->bindValue(':searchText', $searchText, PDO::PARAM_STR);  // ใช้ = แทน LIKE
    $delete_confirm_stmt->execute();

    // ลบข้อมูลใน log_speak ที่ตรงกับเงื่อนไข
    $delete_sql = "DELETE FROM log_speak WHERE username = :username AND words = :searchText";
    $delete_stmt = $conn->prepare($delete_sql);
    $delete_stmt->bindValue(':username', $username, PDO::PARAM_STR);
    $delete_stmt->bindValue(':searchText', $searchText, PDO::PARAM_STR);  // ใช้ = แทน LIKE
    $delete_stmt->execute();

    // ถ้าทุกอย่างสำเร็จให้ commit
    $conn->commit();

    echo json_encode([
        'success' => true,
        'message' => 'ข้อมูลถูกลบเรียบร้อยแล้ว'
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    // หากเกิดข้อผิดพลาดใดๆ จะทำการ rollback และส่งข้อความแสดงข้อผิดพลาด
    if ($conn->inTransaction()) {
        $conn->rollBack();  // Rollback หากมีข้อผิดพลาด
    }
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดำเนินการได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
