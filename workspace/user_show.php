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
    $page = isset($_POST["page"]) ? $_POST["page"] : 1;
    $filter = isset($_POST["filter"]) ? $_POST["filter"] : 'ชื่อทั้งหมด';
    $searchText = isset($_POST["searchText"]) ? $_POST["searchText"] : '';
    $perPage = 50;
    $offset = ($page - 1) * $perPage;
    
    // ตรวจสอบความถูกต้องของ Token ก่อนดำเนินการต่อ
    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    // เริ่มต้นคำสั่ง SQL แบบไดนามิก
    $sql = "SELECT * FROM users";
    $conditions = []; // สร้าง array สำหรับเก็บเงื่อนไข

    if ($filter == 'Admin') {
        $conditions[] = "level_access = 1";
    } elseif ($filter == 'ผู้มีสิทธิ์ยืนยันเสียงอ่าน') {
        $conditions[] = "permission_voice = 1";
    } elseif ($filter == 'รอการยืนยัน') {
        $conditions[] = "active = 0";
    }

    // เพิ่มเงื่อนไขการค้นหาจาก _controlSearchText
    if (!empty($searchText)) {
        $conditions[] = "(username LIKE :searchText OR firstName LIKE :searchText)";
    }

    // ถ้ามีเงื่อนไข ให้เชื่อมด้วย WHERE และ AND
    if (!empty($conditions)) {
        $sql .= " WHERE " . implode(" AND ", $conditions);
    }

    // เพิ่มเงื่อนไขการจัดเรียงและการแบ่งหน้า
    $sql .= " ORDER BY active, birthDate LIMIT :perPage OFFSET :offset";

    $stmt = $conn->prepare($sql);

    // ผูกค่า searchText, perPage, และ offset
    if (!empty($searchText)) {
        $searchParam = "%$searchText%";
        $stmt->bindParam(':searchText', $searchParam, PDO::PARAM_STR);
    }

    $stmt->bindParam(':perPage', $perPage, PDO::PARAM_INT);
    $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();

    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if ($users) {
        // พบผู้ใช้ที่ตรงกับข้อมูลที่รับมา
        echo json_encode([
            'success' => true,
            'message' => 'พบข้อมูล',
            'users' => $users,
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    } else {
        // ไม่พบผู้ใช้
        echo json_encode([
            'success' => false,
            'message' => 'ไม่พบข้อมูลหรือโหลดข้อมูลหมดแล้ว'
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
