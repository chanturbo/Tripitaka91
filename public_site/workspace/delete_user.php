<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {
    $webconfig = new WebsiteConfig();
    $db = new Database();
    $conn = $db->getConnection();

    // ตรวจสอบ Token และรับค่า username
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : '';

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    if (empty($username)) {
        echo json_encode([
            'success' => false,
            'message' => 'กรุณาระบุชื่อผู้ใช้ (username)'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // ลบข้อมูลผู้ใช้งาน
    $sqlDeleteUser = "DELETE FROM users WHERE username = :username";
    $stmtDeleteUser = $conn->prepare($sqlDeleteUser);
    $stmtDeleteUser->bindParam(':username', $username);

    if ($stmtDeleteUser->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'ลบบัญชีผู้ใช้งานเรียบร้อยแล้ว'
        ], JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'ไม่สามารถลบบัญชีผู้ใช้งานได้'
        ], JSON_UNESCAPED_UNICODE);
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'เกิดข้อผิดพลาด: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>

