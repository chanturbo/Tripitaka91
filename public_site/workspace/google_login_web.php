<?php
/**
 * google_login_web.php
 *
 * ปลายทาง "เข้าสู่ระบบด้วย Google" สำหรับหน้าสมาชิกของเว็บ (login.php) —
 * auth ด้วย PHP session (member_session.php) ไม่ใช่ token กลางของแอป
 * ใช้ตรรกะตรวจสอบ/หา-สร้างบัญชีเดียวกับ workspace/google_login.php
 * (ที่แอป Flutter ใช้) ผ่าน workspace/google_auth.php
 *
 * รับ POST:
 *   - credential : Google ID token (JWT) จาก Google Identity Services ฝั่งเบราว์เซอร์
 *   - csrf_token : token กันการปลอมคำขอของหน้า login.php
 */

require_once 'member_session.php';
require_once 'db_connect.php';
require_once 'google_auth.php';

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed'], JSON_UNESCAPED_UNICODE);
    exit;
}

if (!member_csrf_check($_POST['csrf_token'] ?? null)) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'เซสชันหมดอายุ กรุณาโหลดหน้าใหม่'], JSON_UNESCAPED_UNICODE);
    exit;
}

$credential = (string) ($_POST['credential'] ?? '');
$payload = verify_google_id_token($credential);

if ($payload === null) {
    echo json_encode(['success' => false, 'message' => 'Google ID token ไม่ถูกต้องหรือหมดอายุ'], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $db = new Database();
    $conn = $db->getConnection();

    $user = find_or_create_google_user($conn, $payload);

    if ((int) $user['active'] !== 1) {
        echo json_encode(['success' => false, 'message' => 'บัญชีนี้ยังไม่ได้ยืนยัน กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ'], JSON_UNESCAPED_UNICODE);
        exit;
    }

    session_regenerate_id(true);
    $displayName = trim(($user['firstName'] ?? '') . ' ' . ($user['lastName'] ?? ''));
    $_SESSION['member'] = [
        'username' => $user['username'],
        'name' => $displayName !== '' ? $displayName : $user['username'],
        'email' => $user['email'],
        'level_access' => $user['level_access'],
    ];

    echo json_encode(['success' => true, 'message' => 'เข้าสู่ระบบด้วย Google สำเร็จ'], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'ไม่สามารถเชื่อมต่อฐานข้อมูลได้: ' . $e->getMessage()], JSON_UNESCAPED_UNICODE);
}
