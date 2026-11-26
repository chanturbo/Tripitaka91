<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {    
    $webconfig = new WebsiteConfig();
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : '';
    $page = isset($_POST["page"]) ? $_POST["page"] : 1; // รับค่าหน้าที่ต้องการแสดง
    $searchText = isset($_POST["searchText"]) ? $_POST["searchText"] : '';  // รับค่าการค้นหาจากโพสต์

    $limit = 50;
    $offset = ($page - 1) * $limit;

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
    
    // เตรียม SQL Query พร้อมเงื่อนไขค้นหาในฟิลด์ words
    $sql = "SELECT *
            FROM log_speak
            WHERE username = :username";

    // ถ้ามี searchText ให้เพิ่มเงื่อนไขการค้นหา
    if (!empty($searchText)) {
        $sql .= " AND words LIKE :searchText";
    }

    $sql .= " LIMIT 50 OFFSET :offset";  // เพิ่ม LIMIT และ OFFSET

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':username', $username, PDO::PARAM_STR);
    
    // ถ้ามีการค้นหา ให้ bind ค่าของ searchText
    if (!empty($searchText)) {
        $stmt->bindValue(':searchText', '%' . $searchText . '%', PDO::PARAM_STR);
    }
    
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();

    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($result) {
        echo json_encode([
            'success' => true,
            'message' => $result
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'โหลดข้อมูลหมดแล้ว/ไม่พบข้อมูล'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }

} catch (Exception $e) {
    // จัดการข้อผิดพลาดที่เกิดขึ้นจากการเชื่อมต่อหรือการประมวลผล SQL
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
