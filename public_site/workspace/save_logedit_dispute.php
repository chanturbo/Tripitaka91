<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

$conn = null;

try {
    $webconfig = new WebsiteConfig();
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : '';
    $bookid = isset($_POST["bookid"]) ? $_POST["bookid"] : '';
    $bookpage = isset($_POST["bookpage"]) ? $_POST["bookpage"] : '';
    $bookline = isset($_POST["bookline"]) ? $_POST["bookline"] : '';
    $comment = isset($_POST["comment"]) ? $_POST["comment"] : '';

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    if (empty($username) || empty($bookid) || empty($bookpage) || empty($bookline) || empty($comment)) {
        echo json_encode([
            'success' => false,
            'message' => 'กรุณากรอกข้อมูลให้ครบถ้วน'
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    $db = new Database();
    $conn = $db->getConnection();
    $conn->beginTransaction();

    // ต้องเป็นรายการที่ถูกแก้ไขแล้วเท่านั้นจึงจะแจ้งข้อโต้แย้งได้
    $sql_check = "SELECT MAX(book_suscess) AS booksuscess FROM log_edit
        WHERE tripitaka91_book = :bookid AND tripitaka91_page = :bookpage AND tripitaka91_line = :bookline";
    $stmt_check = $conn->prepare($sql_check);
    $stmt_check->bindParam(':bookid', $bookid, PDO::PARAM_INT);
    $stmt_check->bindParam(':bookpage', $bookpage, PDO::PARAM_INT);
    $stmt_check->bindParam(':bookline', $bookline, PDO::PARAM_INT);
    $stmt_check->execute();
    $checkResult = $stmt_check->fetch(PDO::FETCH_ASSOC);

    if (!$checkResult || $checkResult['booksuscess'] != 1) {
        $conn->rollBack();
        echo json_encode([
            'success' => false,
            'message' => 'รายการนี้ยังไม่ได้ถูกแก้ไข ไม่สามารถแจ้งข้อโต้แย้งได้'
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    // กันแจ้งซ้ำขณะที่ยังรอการตรวจสอบจากคนเดิม
    $sql_dup = "SELECT id FROM log_edit_dispute
        WHERE tripitaka91_book = :bookid AND tripitaka91_page = :bookpage AND tripitaka91_line = :bookline
        AND tripitaka91_user = :username AND status = 0";
    $stmt_dup = $conn->prepare($sql_dup);
    $stmt_dup->bindParam(':bookid', $bookid, PDO::PARAM_INT);
    $stmt_dup->bindParam(':bookpage', $bookpage, PDO::PARAM_INT);
    $stmt_dup->bindParam(':bookline', $bookline, PDO::PARAM_INT);
    $stmt_dup->bindParam(':username', $username, PDO::PARAM_STR);
    $stmt_dup->execute();

    if ($stmt_dup->fetch(PDO::FETCH_ASSOC)) {
        $conn->rollBack();
        echo json_encode([
            'success' => false,
            'message' => 'คุณได้แจ้งข้อโต้แย้งนี้ไว้แล้ว กำลังรอการตรวจสอบ'
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    $client_ip = isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : '';

    $sql_insert = "INSERT INTO log_edit_dispute
        (tripitaka91_book, tripitaka91_page, tripitaka91_line, tripitaka91_user, tripitaka91_comment, tripitaka91_ip)
        VALUES (:bookid, :bookpage, :bookline, :username, :comment, :ip)";
    $stmt_insert = $conn->prepare($sql_insert);
    $stmt_insert->bindParam(':bookid', $bookid, PDO::PARAM_INT);
    $stmt_insert->bindParam(':bookpage', $bookpage, PDO::PARAM_INT);
    $stmt_insert->bindParam(':bookline', $bookline, PDO::PARAM_INT);
    $stmt_insert->bindParam(':username', $username, PDO::PARAM_STR);
    $stmt_insert->bindParam(':comment', $comment, PDO::PARAM_STR);
    $stmt_insert->bindParam(':ip', $client_ip, PDO::PARAM_STR);
    $stmt_insert->execute();

    $conn->commit();

    echo json_encode([
        'success' => true,
        'message' => 'แจ้งข้อโต้แย้งเรียบร้อยแล้ว รอการตรวจสอบจากผู้ดูแลระบบ'
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    if ($conn && $conn->inTransaction()) {
        $conn->rollBack();
    }
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดำเนินการได้: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
