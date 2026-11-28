<?php
/**
 * google_auth.php
 *
 * ตรวจสอบ Google ID token และหา/สร้างบัญชีผู้ใช้ที่ตรงกับอีเมล — ใช้ร่วมกันโดย
 * google_login.php (แอป Flutter, auth ด้วย token กลาง) และ google_login_web.php
 * (เว็บ, auth ด้วย PHP session) เพื่อไม่ให้ตรรกะยืนยันตัวตนที่สำคัญนี้
 * ไปซ้ำกันสองที่แล้วหลุดไม่ตรงกันในอนาคต
 */

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
        return null; // token นี้ไม่ได้ออกให้แอป/เว็บเรา
    }
    if (($payload['email_verified'] ?? 'false') !== 'true') {
        return null;
    }
    if ((int) ($payload['exp'] ?? 0) < time()) {
        return null;
    }
    return $payload;
}

/**
 * หาบัญชีเดิมด้วยอีเมล (ไม่ใช่ username) เพราะสมาชิกเดิมของระบบจำนวนมากตั้ง
 * username เป็นชื่อเล่น/ชื่อจริง ไม่ใช่อีเมล — ถ้ามีบัญชีที่ใช้อีเมลนี้อยู่แล้ว
 * ให้ผูกบัญชี Google เข้ากับบัญชีเดิม แทนที่จะสร้างบัญชีใหม่ซ้ำซ้อน
 * ยังไม่มี -> สร้างใหม่ทันที ไม่ต้องรอยืนยัน (username = email)
 * คืนแถว users ทั้งแถว
 */
function find_or_create_google_user(PDO $conn, array $payload): array
{
    $sub = (string) $payload['sub'];
    $email = strtolower((string) $payload['email']);
    $name = (string) ($payload['name'] ?? '');

    $stmtFind = $conn->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
    $stmtFind->bindValue(':email', $email);
    $stmtFind->execute();
    $user = $stmtFind->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        $stmtUpdate = $conn->prepare('UPDATE users SET google_sub = :sub WHERE username = :username');
        $stmtUpdate->bindValue(':sub', $sub);
        $stmtUpdate->bindValue(':username', $user['username']);
        $stmtUpdate->execute();
        $user['google_sub'] = $sub;
        return $user;
    }

    $username = $email;
    $hashedPassword = password_hash(bin2hex(random_bytes(16)), PASSWORD_DEFAULT);
    $today = date('Y-m-d');
    $firstName = $name !== '' ? $name : $email;

    $stmtInsert = $conn->prepare(
        'INSERT INTO users
            (username, password, firstName, lastName, birthDate, email, active, level_access, google_sub)
         VALUES (:username, :password, :firstName, :lastName, :birthDate, :email, 1, 2, :sub)'
    );
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
    return $stmtFetch->fetch(PDO::FETCH_ASSOC);
}
