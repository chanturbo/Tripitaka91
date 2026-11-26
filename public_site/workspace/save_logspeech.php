<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {
    $webconfig = new WebsiteConfig();
    $db = new Database(); // สร้างอ็อบเจกต์ Database
    $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO
    
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : '';
    $words = isset($_POST["words"]) ? $_POST["words"] : '';
    $words_speak = isset($_POST["words_speak"]) ? $_POST["words_speak"] : '';
    $comments = isset($_POST["comments"]) ? $_POST["comments"] : '-';
    $words_length = strlen($words); // ปรับชื่อตัวแปรเป็น $words_length และแก้คำผิดเป็น words_length

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }
    
    if (($words == '') || ($words_speak == '') || ($username == '')) { // แก้ไขเงื่อนไขการตรวจสอบข้อมูลที่จะบันทึก
        echo json_encode([
            'success' => false,
            'message' => 'ไม่มีข้อมูลที่จะบันทึก'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        die();
    }

    $conn->beginTransaction(); // เริ่ม Transaction

    // ตรวจสอบว่าคำนี้มีการบันทึกแล้วหรือไม่
    $check_sql = "SELECT * FROM log_speak WHERE words = ?";
    $check_stmt = $conn->prepare($check_sql);
    $check_stmt->execute([$words]);
    $existing_data = $check_stmt->fetch(PDO::FETCH_ASSOC);

    if ($existing_data) { // ถ้ามีข้อมูลในฐานข้อมูลแล้ว
        echo json_encode([
            'success' => false,
            'message' => "คำว่า $words มีการแจ้งการอ่านออกเสียงแล้วโดยคุณ $username"
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        die();
    }

    // บันทึกข้อมูลลงในฐานข้อมูล
    $insert_sql = "INSERT INTO log_speak (words, words_speak, words_length, words_comfirm, comments, username) VALUES (:words, :words_speak, :words_length, :words_comfirm, :comments, :username)";
    $insert_stmt = $conn->prepare($insert_sql);
    $insert_stmt->bindValue(':words', $words, PDO::PARAM_STR);
    $insert_stmt->bindValue(':words_speak', $words_speak, PDO::PARAM_STR);
    $insert_stmt->bindValue(':words_length', $words_length, PDO::PARAM_INT);
    $insert_stmt->bindValue(':words_comfirm', 0, PDO::PARAM_INT); // ให้ค่า words_comfirm เป็น 1 โดยตรง
    $insert_stmt->bindValue(':comments', $comments, PDO::PARAM_STR);
    $insert_stmt->bindValue(':username', $username, PDO::PARAM_STR);
    $insert_stmt->execute();

    // ตรวจสอบว่าการ insert เรียบร้อย
    if ($insert_stmt) {
        // // สร้างข้อมูลการยืนยันในตาราง log_speak_confirm
        // $client_ip = $_SERVER['REMOTE_ADDR'];
        // $confirm_sql = "INSERT INTO log_speak_confirm (words, tripitaka91_user, tripitaka91_ip) VALUES (:words, :username, :client_ip)";
        // $confirm_stmt = $conn->prepare($confirm_sql);
        // $confirm_stmt->bindValue(':words', $words, PDO::PARAM_STR);
        // $confirm_stmt->bindValue(':username', $username, PDO::PARAM_STR);
        // $confirm_stmt->bindValue(':client_ip', $client_ip, PDO::PARAM_STR);
        // $confirm_stmt->execute();

        $conn->commit(); // ยืนยัน Transaction

        // ส่ง JSON response กลับไปที่ Flutter
        echo json_encode([
            'success' => true,
            'message' => "บันทึก $words เรียบร้อยแล้ว"
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    } else {
        // ยกเลิก Transaction และจัดการข้อผิดพลาด
        $conn->rollBack();
        echo json_encode([
            'success' => false,
            'message' => 'ไม่สามารถบันทึกข้อมูลได้'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }

} catch (Exception $e) {
    // ยกเลิก Transaction และจัดการข้อผิดพลาด
    $conn->rollBack();
    echo json_encode([
        'success' => false,
        'message' => 'เกิดข้อผิดพลาด: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
