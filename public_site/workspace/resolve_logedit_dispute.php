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
    $action = isset($_POST["action"]) ? $_POST["action"] : '';

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    if (empty($bookid) || empty($bookpage) || empty($bookline) || ($action != 'revert' && $action != 'reject')) {
        echo json_encode([
            'success' => false,
            'message' => 'ไม่พบข้อมูลที่ส่งมา หรือ action ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    $db = new Database();
    $conn = $db->getConnection();
    $conn->beginTransaction();

    if ($action == 'reject') {
        $sql_reject = "UPDATE log_edit_dispute
            SET status = 2, resolved_by = :username, resolved_at = NOW()
            WHERE tripitaka91_book = :bookid AND tripitaka91_page = :bookpage AND tripitaka91_line = :bookline
            AND status = 0";
        $stmt_reject = $conn->prepare($sql_reject);
        $stmt_reject->bindParam(':username', $username, PDO::PARAM_STR);
        $stmt_reject->bindParam(':bookid', $bookid, PDO::PARAM_INT);
        $stmt_reject->bindParam(':bookpage', $bookpage, PDO::PARAM_INT);
        $stmt_reject->bindParam(':bookline', $bookline, PDO::PARAM_INT);
        $stmt_reject->execute();

        $conn->commit();
        echo json_encode([
            'success' => true,
            'message' => 'ปฏิเสธข้อโต้แย้งเรียบร้อยแล้ว'
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    // action == 'revert'
    $sql_history = "SELECT id, book_detail_before, book_detail_old_before
        FROM log_edit_history
        WHERE tripitaka91_book = :bookid AND tripitaka91_page = :bookpage AND tripitaka91_line = :bookline
        AND reverted_at IS NULL
        ORDER BY applied_at DESC
        LIMIT 1";
    $stmt_history = $conn->prepare($sql_history);
    $stmt_history->bindParam(':bookid', $bookid, PDO::PARAM_INT);
    $stmt_history->bindParam(':bookpage', $bookpage, PDO::PARAM_INT);
    $stmt_history->bindParam(':bookline', $bookline, PDO::PARAM_INT);
    $stmt_history->execute();
    $historyRow = $stmt_history->fetch(PDO::FETCH_ASSOC);

    if (!$historyRow) {
        $conn->rollBack();
        echo json_encode([
            'success' => false,
            'message' => 'ไม่พบข้อมูลย้อนกลับสำหรับบรรทัดนี้ (อาจถูกแก้ไขก่อนมีระบบบันทึกย้อนหลัง) กรุณาตรวจสอบและแก้ไขด้วยตนเอง'
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    $historyId = $historyRow['id'];
    $detailBefore = $historyRow['book_detail_before'];
    $detailOldBefore = $historyRow['book_detail_old_before'];

    $sql_restore = "UPDATE tripitaka91_91book_line
        SET book_detail = :detail_before, book_detail_old = :detail_old_before
        WHERE book_id = :bookid AND book_pages = :bookpage AND book_lines = :bookline";
    $stmt_restore = $conn->prepare($sql_restore);
    $stmt_restore->bindParam(':detail_before', $detailBefore, PDO::PARAM_STR);
    $stmt_restore->bindParam(':detail_old_before', $detailOldBefore, PDO::PARAM_STR);
    $stmt_restore->bindParam(':bookid', $bookid, PDO::PARAM_INT);
    $stmt_restore->bindParam(':bookpage', $bookpage, PDO::PARAM_INT);
    $stmt_restore->bindParam(':bookline', $bookline, PDO::PARAM_INT);
    $stmt_restore->execute();

    $sql_consume = "UPDATE log_edit_history
        SET reverted_at = NOW(), reverted_by = :username
        WHERE id = :history_id";
    $stmt_consume = $conn->prepare($sql_consume);
    $stmt_consume->bindParam(':username', $username, PDO::PARAM_STR);
    $stmt_consume->bindParam(':history_id', $historyId, PDO::PARAM_INT);
    $stmt_consume->execute();

    // รีเซ็ตให้บรรทัดนี้กลับไปอยู่ในสถานะ "ยังไม่ยืนยัน" เพื่อรอเสนอ/ยืนยันใหม่
    $sql_reset = "UPDATE log_edit
        SET book_suscess = 0, book_confirm = 0
        WHERE tripitaka91_book = :bookid AND tripitaka91_page = :bookpage AND tripitaka91_line = :bookline";
    $stmt_reset = $conn->prepare($sql_reset);
    $stmt_reset->bindParam(':bookid', $bookid, PDO::PARAM_INT);
    $stmt_reset->bindParam(':bookpage', $bookpage, PDO::PARAM_INT);
    $stmt_reset->bindParam(':bookline', $bookline, PDO::PARAM_INT);
    $stmt_reset->execute();

    $sql_clear_confirm = "DELETE FROM log_edit_confirm
        WHERE tripitaka91_book = :bookid AND tripitaka91_page = :bookpage AND tripitaka91_line = :bookline";
    $stmt_clear_confirm = $conn->prepare($sql_clear_confirm);
    $stmt_clear_confirm->bindParam(':bookid', $bookid, PDO::PARAM_INT);
    $stmt_clear_confirm->bindParam(':bookpage', $bookpage, PDO::PARAM_INT);
    $stmt_clear_confirm->bindParam(':bookline', $bookline, PDO::PARAM_INT);
    $stmt_clear_confirm->execute();

    $sql_resolve = "UPDATE log_edit_dispute
        SET status = 1, resolved_by = :username, resolved_at = NOW(), history_id = :history_id
        WHERE tripitaka91_book = :bookid AND tripitaka91_page = :bookpage AND tripitaka91_line = :bookline
        AND status = 0";
    $stmt_resolve = $conn->prepare($sql_resolve);
    $stmt_resolve->bindParam(':username', $username, PDO::PARAM_STR);
    $stmt_resolve->bindParam(':history_id', $historyId, PDO::PARAM_INT);
    $stmt_resolve->bindParam(':bookid', $bookid, PDO::PARAM_INT);
    $stmt_resolve->bindParam(':bookpage', $bookpage, PDO::PARAM_INT);
    $stmt_resolve->bindParam(':bookline', $bookline, PDO::PARAM_INT);
    $stmt_resolve->execute();

    $conn->commit();

    echo json_encode([
        'success' => true,
        'message' => 'ย้อนกลับข้อมูลเรียบร้อยแล้ว'
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
