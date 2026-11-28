<?php
/**
 * member_session.php
 *
 * Session ของ "หน้าสมาชิก" ฝั่งเว็บ (login.php/member.php/member_api.php)
 * แยกจาก token กลางที่แอป Flutter ใช้ (websiteconfig.php->getToken()) โดยสิ้นเชิง —
 * หน้าเว็บกลุ่มนี้ auth ด้วย PHP session ของเบราว์เซอร์เอง ไม่ใช่ token ที่ฝังในแอป
 */

if (session_status() === PHP_SESSION_NONE) {
    $isHttps = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');
    session_set_cookie_params([
        'lifetime' => 0,
        'path' => '/',
        'domain' => '',
        'secure' => $isHttps,
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    session_start();
}

function member_logged_in(): bool
{
    return isset($_SESSION['member']['username']) && $_SESSION['member']['username'] !== '';
}

function member_current(): array
{
    return $_SESSION['member'] ?? [];
}

function member_require_login(string $redirectTo = 'login.php'): void
{
    if (!member_logged_in()) {
        header('Location: ' . $redirectTo);
        exit;
    }
}

function member_csrf_token(): string
{
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

function member_csrf_check(?string $token): bool
{
    return isset($_SESSION['csrf_token']) && is_string($token) && $token !== '' && hash_equals($_SESSION['csrf_token'], $token);
}
