<?php
require_once 'workspace/member_session.php';
require_once 'workspace/db_connect.php';

// แฮชปลอม (ไม่ผูกกับบัญชีจริงใดๆ) ใช้ตอนไม่พบ user เพื่อให้ password_verify()
// ยังคงถูกเรียกเสมอ เวลาที่ใช้จะไม่ต่างจากกรณีพบ user แต่รหัสผ่านผิด —
// ป้องกันการเดา username/email ที่มีอยู่จริงจากความต่างของเวลาตอบสนอง
const DUMMY_PASSWORD_HASH = '$2y$10$m47kjdweD51q7WrRLShN3uRzn2i8/thJtTwSGoXJFmC5wVfUkfXFG';

if (member_logged_in()) {
    header('Location: member.php');
    exit;
}

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!member_csrf_check($_POST['csrf_token'] ?? null)) {
        $error = 'เซสชันหมดอายุ กรุณาลองใหม่อีกครั้ง';
    } else {
        $identifier = trim((string) ($_POST['identifier'] ?? ''));
        $password = (string) ($_POST['password'] ?? '');

        if ($identifier === '' || $password === '') {
            $error = 'กรุณากรอกชื่อผู้ใช้/อีเมลและรหัสผ่าน';
        } else {
            try {
                $db = new Database();
                $conn = $db->getConnection();
                $stmt = $conn->prepare(
                    'SELECT username, password, firstName, lastName, email, active, level_access
                     FROM users WHERE username = :identifier OR email = :identifier LIMIT 1'
                );
                $stmt->bindValue(':identifier', $identifier, PDO::PARAM_STR);
                $stmt->execute();
                $user = $stmt->fetch(PDO::FETCH_ASSOC);
                $passwordOk = password_verify($password, $user['password'] ?? DUMMY_PASSWORD_HASH);

                if (!$user || !$passwordOk) {
                    $error = 'ชื่อผู้ใช้/อีเมล หรือรหัสผ่านไม่ถูกต้อง';
                } elseif ((int) $user['active'] !== 1) {
                    $error = 'บัญชีนี้ยังไม่ได้ยืนยัน กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ';
                } else {
                    session_regenerate_id(true);
                    $displayName = trim(($user['firstName'] ?? '') . ' ' . ($user['lastName'] ?? ''));
                    $_SESSION['member'] = [
                        'username' => $user['username'],
                        'name' => $displayName !== '' ? $displayName : $user['username'],
                        'email' => $user['email'],
                        'level_access' => $user['level_access'],
                    ];
                    header('Location: member.php');
                    exit;
                }
            } catch (Exception $e) {
                $error = 'ไม่สามารถเชื่อมต่อฐานข้อมูลได้ กรุณาลองใหม่อีกครั้ง';
            }
        }
    }
}

$csrfToken = member_csrf_token();
?>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>เข้าสู่ระบบสมาชิก - Tripitaka91</title>
    <link rel="shortcut icon" href="favicon.png">
    <link href="tri91_legacy/css/bootstrap.min.css" rel="stylesheet">
    <link href="tri91_legacy/font-awesome/css/font-awesome.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Thai:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root{
            --navy:#2c3e50; --navy-dark:#1c2733; --teal:#18bc9c; --teal-dark:#149d82;
            --border:#e6e9ef; --text-muted:#8a94a6;
        }
        *{ box-sizing:border-box; }
        html, body{ height:100%; }
        body{
            background:
                radial-gradient(circle at 15% 15%, rgba(24,188,156,.18), transparent 40%),
                radial-gradient(circle at 85% 85%, rgba(24,188,156,.10), transparent 45%),
                linear-gradient(135deg, var(--navy) 0%, var(--navy-dark) 100%);
            font-family:"Noto Sans Thai","Segoe UI","Lato",sans-serif;
            min-height:100vh;
            display:flex;
            align-items:center;
            justify-content:center;
            padding:24px;
            -webkit-font-smoothing:antialiased;
        }
        .login-box{
            background:#fff;
            max-width:400px;
            width:100%;
            padding:36px 34px 30px;
            border-radius:16px;
            border-top:4px solid var(--teal);
            box-shadow:0 20px 50px rgba(10,20,35,.35);
        }
        .login-box .brand{
            display:flex; flex-direction:column; align-items:center; margin-bottom:22px;
        }
        .login-box .brand .logo-chip{
            width:54px; height:54px; border-radius:16px; background:rgba(24,188,156,.12);
            color:var(--teal-dark); display:flex; align-items:center; justify-content:center;
            font-size:24px; margin-bottom:12px;
        }
        .login-box h1{
            font-size:19px; font-weight:700; margin:0; text-align:center; color:var(--navy);
        }
        .login-box .subtitle{ color:var(--text-muted); font-size:13px; margin-top:4px; }
        .alert{ border-radius:8px; font-size:13.5px; }
        .divider{
            text-align:center; color:var(--text-muted); margin:20px 0; font-size:13px;
            display:flex; align-items:center;
        }
        .divider::before, .divider::after{
            content:""; flex:1; border-bottom:1px solid var(--border);
        }
        .divider span{ padding:0 12px; }
        #g_id_signin_container{ display:flex; justify-content:center; margin-bottom:4px; }
        .login-box .form-group label{
            font-size:13px; font-weight:600; color:var(--navy); margin-bottom:5px;
        }
        .login-box .form-control{
            border-radius:8px; border:1px solid var(--border); height:42px; padding:8px 14px;
            box-shadow:none; transition:border-color .15s ease, box-shadow .15s ease;
        }
        .login-box .form-control:focus{
            border-color:var(--teal); box-shadow:0 0 0 3px rgba(24,188,156,.15);
        }
        .login-box .btn-primary{
            background:var(--teal); border-color:var(--teal); border-radius:8px;
            font-weight:600; height:44px; margin-top:6px; transition:background .15s ease;
        }
        .login-box .btn-primary:hover, .login-box .btn-primary:focus{
            background:var(--teal-dark); border-color:var(--teal-dark);
        }
        .login-box .back-link{ margin-top:18px; font-size:13.5px; }
        .login-box .back-link a{ color:var(--text-muted); }
        .login-box .back-link a:hover{ color:var(--teal-dark); }
    </style>
</head>
<body>
    <div class="login-box">
        <div class="brand">
            <span class="logo-chip"><i class="fa fa-book"></i></span>
            <h1>เข้าสู่ระบบสมาชิก</h1>
            <div class="subtitle">Tripitaka91 &middot; พระไตรปิฎกและอรรถกถาแปล</div>
        </div>

        <div class="alert alert-danger" id="google-login-error" style="display:none;"></div>
        <?php if ($error !== ''): ?>
            <div class="alert alert-danger"><?php echo htmlspecialchars($error, ENT_QUOTES, 'UTF-8'); ?></div>
        <?php endif; ?>

        <div id="g_id_onload"
             data-client_id="678536711643-1p9avbk9b8t9tu3r8i4f8crkn8ap566k.apps.googleusercontent.com"
             data-callback="handleGoogleCredential"
             data-auto_prompt="false">
        </div>
        <div id="g_id_signin_container">
            <div class="g_id_signin" data-type="standard" data-shape="pill" data-width="330" data-locale="th"></div>
        </div>

        <div class="divider"><span>หรือ</span></div>

        <form method="post" action="login.php">
            <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($csrfToken, ENT_QUOTES, 'UTF-8'); ?>">
            <div class="form-group">
                <label>ชื่อผู้ใช้ หรือ อีเมล</label>
                <input type="text" class="form-control" name="identifier" required autofocus>
            </div>
            <div class="form-group">
                <label>รหัสผ่าน</label>
                <input type="password" class="form-control" name="password" required>
            </div>
            <button type="submit" class="btn btn-primary btn-block">เข้าสู่ระบบ</button>
        </form>
        <p class="text-center back-link">
            <a href="tripitaka91.php"><i class="fa fa-angle-left"></i> กลับหน้าแรก</a>
        </p>
    </div>

    <script src="https://accounts.google.com/gsi/client" async defer></script>
    <script>
        var CSRF_TOKEN = <?php echo json_encode($csrfToken); ?>;

        function handleGoogleCredential(response) {
            var errorBox = document.getElementById('google-login-error');
            errorBox.style.display = 'none';

            var body = new URLSearchParams();
            body.set('credential', response.credential);
            body.set('csrf_token', CSRF_TOKEN);

            fetch('workspace/google_login_web.php', { method: 'POST', body: body })
                .then(function (r) { return r.json(); })
                .then(function (res) {
                    if (res.success) {
                        window.location.href = 'member.php';
                        return;
                    }
                    errorBox.textContent = res.message || 'เข้าสู่ระบบด้วย Google ไม่สำเร็จ';
                    errorBox.style.display = 'block';
                })
                .catch(function () {
                    errorBox.textContent = 'ไม่สามารถติดต่อเซิร์ฟเวอร์ได้ กรุณาลองใหม่อีกครั้ง';
                    errorBox.style.display = 'block';
                });
        }
    </script>
</body>
</html>
