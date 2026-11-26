<?php

require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

try {
    $webconfig = new WebsiteConfig();
    $searchWord = isset($_POST["searchWord"]) ? $_POST["searchWord"] : '';
    $token = isset($_POST["token"]) ? $_POST["token"] : '';

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        die();
    }

    // ตรวจสอบว่า searchWord ไม่ใช่ค่าว่าง
    if (empty($searchWord)) {
        echo json_encode([
            'success' => false,
            'message' => 'โปรดระบุคำค้นหา'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        die();
    }

    $db = new Database();
    $conn = $db->getConnection();
    
    // คำสั่ง SQL เพื่อค้นหาคำในฟิลด์ words จากตาราง log_speak
    $sql = "SELECT * FROM log_speak WHERE words = :searchWord";
    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':searchWord', $searchWord, PDO::PARAM_STR);

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
            'message' => 'ไม่พบข้อมูล'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
