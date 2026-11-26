<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {
    $webconfig = new WebsiteConfig();
    $db = new Database(); // สร้างอ็อบเจกต์ Database
    $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO

    // ตรวจสอบความถูกต้องของ Token ก่อนดำเนินการต่อ
    $token = isset($_POST["token"]) ? $_POST["token"] : '';    
    $username = isset($_POST["username"]) ? $_POST["username"] : '';
    $password = isset($_POST["password"]) ? $_POST["password"] : '';
    $first_nameid = isset($_POST["first_nameid"]) ? $_POST["first_nameid"] : '';
    $first_name = isset($_POST["first_name"]) ? $_POST["first_name"] : '';
    $last_name = isset($_POST["last_name"]) ? $_POST["last_name"] : '';
    $dateofbirth = isset($_POST["dateofbirth"]) ? $_POST["dateofbirth"] : '';
    $email = isset($_POST["email"]) ? $_POST["email"] : '';
    
    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    // เข้ารหัสรหัสผ่าน
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    // ทำการเพิ่มข้อมูลลงในฐานข้อมูล
    $sqlInsertUser = "INSERT INTO users (username, password, first_nameid, firstName, lastName, birthDate, email) 
    VALUES (:username, :password, :first_nameid, :firstName, :lastName, :birthDate, :email)";
    $stmtInsertUser = $conn->prepare($sqlInsertUser);

    // ทำการเชื่อมโยงพารามิเตอร์
    $stmtInsertUser->bindParam(':username', $username);
    $stmtInsertUser->bindParam(':password', $hashedPassword); // ใช้รหัสผ่านที่เข้ารหัสแล้ว
    $stmtInsertUser->bindParam(':first_nameid', $first_nameid);
    $stmtInsertUser->bindParam(':firstName', $first_name);
    $stmtInsertUser->bindParam(':lastName', $last_name);
    $stmtInsertUser->bindParam(':birthDate', $dateofbirth);
    $stmtInsertUser->bindParam(':email', $email);

    // ทำการเพิ่มข้อมูลลงในฐานข้อมูล
    $stmtInsertUser->execute();

    // ส่ง response กลับไปยัง Flutter
    echo json_encode([
        'success' => true,
        'message' => 'บันทึกข้อมูลผู้ใช้งานใหม่เรียบร้อย',
        'user' => [
            'username' => $username,
            'password' => $hashedPassword,
            'first_nameid' => $first_nameid,
            'first_name' => $first_name,
            'last_name' => $last_name,
            'dateofbirth' => $dateofbirth,
            'email' => $email,
        ],
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    // จัดการข้อผิดพลาดที่เกิดขึ้นจากการเชื่อมต่อหรือการประมวลผล SQL
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถติดต่อฐานข้อมูลได้: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
