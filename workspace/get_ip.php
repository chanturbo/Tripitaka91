<?
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {
    $webconfig = new WebsiteConfig();
    $token = isset($_POST["token"]) ? $_POST["token"] : '';

    // ตรวจสอบความถูกต้องของ Token ก่อนดำเนินการต่อ
    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    // ถ้า Token ถูกต้อง, ดำเนินการต่อไป
    // ตรวจสอบ IP address หรือทำอย่างอื่นๆ ตามที่คุณต้องการทำ
    // $ip_address = $_SERVER['REMOTE_ADDR'];
    $ip_address = $_SERVER['HTTP_X_FORWARDED_FOR'];
    

    // สร้าง associative array เพื่อเก็บข้อมูลที่ต้องการส่งใน JSON
    $response = array(
        'success' => true,
        'message' => 'Token ถูกต้อง',
        'ip_address' => $ip_address
    );

    // แปลง associative array เป็น JSON และแสดงผล
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'เกิดข้อผิดพลาด: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>