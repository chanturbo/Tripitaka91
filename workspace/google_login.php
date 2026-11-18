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
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

// Client ID ของ Google Cloud project "Tripitaka91" (ค่าเดียวกับ tGoogleWebClientId ในแอป)
const GOOGLE_WEB_CLIENT_ID = '678536711643-1p9avbk9b8t9tu3r8i4f8crkn8ap566k.apps.googleusercontent.com';

/**
 * ตรวจ Google ID token กับ Google tokeninfo endpoint ตรงๆ (ไม่ต้องติดตั้ง JWT library)
 * คืน payload (sub, email, email_verified, name, ...) หรือ null ถ้าไม่ผ่าน
 */
function verify_google_id_token(string $idToken): ?array
{
    if ($idToken === '') {
        return null;
    }
    $url = 'https://oauth2.googleapis.com/tokeninfo?id_token=' . urlencode($idToken);
    $ctx = stream_context_create(['http' => ['timeout' => 8, 'ignore_errors' => true]]);
    $raw = @file_get_contents($url, false, $ctx);
    if ($raw === false) {
        return null;
    }
    $payload = json_decode($raw, true);
    if (!is_array($payload) || isset($payload['error'])) {
        return null;
    }
    if (($payload['aud'] ?? '') !== GOOGLE_WEB_CLIENT_ID) {
        return null; // token นี้ไม่ได้ออกให้แอปเรา
    }
    if (($payload['email_verified'] ?? 'false') !== 'true') {
        return null;
    }
    if ((int) ($payload['exp'] ?? 0) < time()) {
        return null;
    }
    return $payload;
}

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

    $sub = (string) $payload['sub'];
    $email = strtolower((string) $payload['email']);
    $name = (string) ($payload['name'] ?? '');

    // หา user เดิมด้วยอีเมล (ไม่ใช่ username) เพราะสมาชิกเดิมของระบบจำนวนมาก
    // ตั้ง username เป็นชื่อเล่น/ชื่อจริง ไม่ใช่อีเมล — ถ้ามีบัญชีที่ใช้อีเมลนี้อยู่แล้ว
    // ให้ผูกบัญชี Google เข้ากับบัญชีเดิม แทนที่จะสร้างบัญชีใหม่ซ้ำซ้อน
    $sqlFind = 'SELECT * FROM users WHERE email = :email LIMIT 1';
    $stmtFind = $conn->prepare($sqlFind);
    $stmtFind->bindValue(':email', $email);
    $stmtFind->execute();
    $user = $stmtFind->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        // มีบัญชีอยู่แล้ว -> ผูก google_sub ไว้ (ไม่แก้สิทธิ์/รหัสผ่านเดิม)
        $stmtUpdate = $conn->prepare('UPDATE users SET google_sub = :sub WHERE username = :username');
        $stmtUpdate->bindValue(':sub', $sub);
        $stmtUpdate->bindValue(':username', $user['username']);
        $stmtUpdate->execute();
        $user['google_sub'] = $sub;
    } else {
        // ยังไม่มี user นี้ในระบบ -> สร้างใหม่ทันที ไม่ต้องรอยืนยัน (username = email)
        $username = $email;
        $hashedPassword = password_hash(bin2hex(random_bytes(16)), PASSWORD_DEFAULT);
        $today = date('Y-m-d');
        $firstName = $name !== '' ? $name : $email;

        $sqlInsert = 'INSERT INTO users
                (username, password, firstName, lastName, birthDate, email, active, level_access, google_sub)
            VALUES (:username, :password, :firstName, :lastName, :birthDate, :email, 1, 2, :sub)';
        $stmtInsert = $conn->prepare($sqlInsert);
        $stmtInsert->bindValue(':username', $username);
        $stmtInsert->bindValue(':password', $hashedPassword);
        $stmtInsert->bindValue(':firstName', $firstName);
        $stmtInsert->bindValue(':lastName', '');
        $stmtInsert->bindValue(':birthDate', $today);
        $stmtInsert->bindValue(':email', $email);
        $stmtInsert->bindValue(':sub', $sub);
        $stmtInsert->execute();

        $stmtFetch = $conn->prepare('SELECT * FROM users WHERE username = :username LIMIT 1');
        $stmtFetch->bindValue(':username', $username);
        $stmtFetch->execute();
        $user = $stmtFetch->fetch(PDO::FETCH_ASSOC);
    }

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
