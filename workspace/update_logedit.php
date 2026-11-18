<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {    
    $webconfig = new WebsiteConfig();
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : '';
    $bookid = isset($_POST["bookid"]) ? $_POST["bookid"] : '';
    $bookpage = isset($_POST["bookpage"]) ? $_POST["bookpage"] : '';
    $bookline = isset($_POST["bookline"]) ? $_POST["bookline"] : '';
    $bookdetail = isset($_POST["bookdetail"]) ? $_POST["bookdetail"] : '';
    
    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    // เพิ่มเงื่อนไขเพื่อตรวจสอบว่า username ไม่เป็นค่าว่าง
    if (empty($username)) {
        echo json_encode([
            'success' => false,
            'message' => 'กรุณากรอกชื่อผู้ใช้'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า username เป็นค่าว่าง
    }
        
    $db = new Database(); // สร้างอ็อบเจกต์ Database
    $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO
    
    // เริ่ม Transaction
    $conn->beginTransaction();

    // กำหนด SQL UPDATE 
    $sql_update = "UPDATE log_edit
                   SET book_detail_new = :bookdetail,
                       book_confirm = 1
                   WHERE tripitaka91_book = :bookid
                   AND tripitaka91_page = :bookpage
                   AND tripitaka91_line = :bookline";

    $stmt_update = $conn->prepare($sql_update);
    $stmt_update->bindValue(':bookdetail', $bookdetail, PDO::PARAM_STR);
    $stmt_update->bindValue(':bookid', $bookid, PDO::PARAM_STR);
    $stmt_update->bindValue(':bookpage', $bookpage, PDO::PARAM_INT);
    $stmt_update->bindValue(':bookline', $bookline, PDO::PARAM_INT);
    $stmt_update->execute();

    // ตรวจสอบว่ามีการอัปเดตเรียบร้อย
    $rowsAffected = $stmt_update->rowCount();
    if ($rowsAffected <= 0) {
        $conn->rollBack(); // ถ้าไม่มีการอัปเดตให้ยกเลิก Transaction และส่งข้อความว่าไม่สามารถอัปเดตข้อมูลได้
        echo json_encode([
            'success' => false,
            'message' => 'ไม่พบข้อมูลที่ต้องการอัปเดต'
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    // กำหนด SQL INSERT    
    $sql_insert = "INSERT INTO log_edit_confirm (tripitaka91_book, tripitaka91_page, tripitaka91_line, tripitaka91_user, tripitaka91_ip)
                   VALUES (:bookid, :bookpage, :bookline, :username, :ip)";

    $stmt_insert = $conn->prepare($sql_insert);
    $stmt_insert->bindValue(':bookid', $bookid, PDO::PARAM_INT);
    $stmt_insert->bindValue(':bookpage', $bookpage, PDO::PARAM_INT);
    $stmt_insert->bindValue(':bookline', $bookline, PDO::PARAM_INT);
    $stmt_insert->bindValue(':username', $username, PDO::PARAM_STR);
    // รับค่า IP address จากผู้ใช้
    $client_ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
    $stmt_insert->bindValue(':ip', $client_ip, PDO::PARAM_STR);

    $stmt_insert->execute();

    // Commit Transaction เมื่อไม่มีข้อผิดพลาดเกิดขึ้นในการประมวลผล
    $conn->commit();

    echo json_encode([
        'success' => true,
        'message' => 'อัปเดตข้อมูลและบันทึกข้อมูลเข้าฐานข้อมูลเรียบร้อย'
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    // Rollback Transaction ในกรณีที่เกิดข้อผิดพลาด
    $conn->rollBack();
    // จัดการข้อผิดพลาดที่เกิดขึ้นจากการเชื่อมต่อหรือการประมวลผล SQL
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดำเนินการได้: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
