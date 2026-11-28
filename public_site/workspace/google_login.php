<?php
/**
 * google_login.php
 *
 * ปลายทาง "เข้าสู่ระบบด้วย Google" จากแอป Tripitaka91 (Flutter)
 * ใช้ require_once เดียวกับ user_chk.php/user_save.php (db_connect.php, websiteconfig.php)
 *
 * รับ POST:
 *   - id_token : Google ID token (JWT) ที่ได้จาก google_sign_in ฝั่งแอป
 *   - token    : secret API key เดียวกับที่ endpoint อื่นๆ ใช้ (tSecretAPIKey ในแอป)
 *
 * คืน JSON รูปแบบเดียวกับ user_chk.php: {success, message, user: {...แถวจาก users ทั้งแถว...}}
 */

require_once 'db_connect.php';
require_once 'websiteconfig.php';
require_once 'google_auth.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {
    $webconfig = new WebsiteConfig();
    $db = new Database(); // สร้างอ็อบเจกต์ Database
    $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO

    $token = isset($_POST['token']) ? $_POST['token'] : '';
    $idToken = isset($_POST['id_token']) ? $_POST['id_token'] : '';

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง',
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    $payload = verify_google_id_token($idToken);
    if ($payload === null) {
        echo json_encode([
            'success' => false,
            'message' => 'Google ID token ไม่ถูกต้องหรือหมดอายุ',
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    $user = find_or_create_google_user($conn, $payload);

    if ((int) $user['active'] !== 1) {
        echo json_encode([
            'success' => false,
            'message' => 'บัญชีนี้ยังไม่ได้ยืนยัน กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ',
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    // ไม่ส่ง password hash กลับไปให้ไคลเอนต์ — แอปไม่ได้ใช้ค่านี้ทำอะไร
    // (เก็บไว้ในโมเดลผู้ใช้ในเครื่องเฉยๆ) จึงไม่มีเหตุผลต้องส่งความลับนี้ออกไป
    unset($user['password']);

    echo json_encode([
        'success' => true,
        'message' => 'เข้าสู่ระบบด้วย Google สำเร็จ',
        'user' => $user,
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถติดต่อฐานข้อมูลได้: ' . $e->getMessage(),
    ], JSON_UNESCAPED_UNICODE);
}
