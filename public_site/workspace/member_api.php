<?php
/**
 * member_api.php
 *
 * Backend AJAX เดียวสำหรับหน้าสมาชิก (member.php) — auth ด้วย PHP session
 * (member_session.php) ไม่ใช่ token กลางของแอป ดังนั้น "username" ที่ใช้กรองข้อมูล
 * ทุก query มาจาก session เท่านั้น ไม่รับจาก client เพื่อไม่ให้สมาชิกคนหนึ่ง
 * ดึงข้อมูลของอีกคนได้โดยแก้ parameter เอง
 */

require_once 'member_session.php';
require_once 'db_connect.php';

header('Content-Type: application/json; charset=utf-8');

if (!member_logged_in()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'กรุณาเข้าสู่ระบบก่อน'], JSON_UNESCAPED_UNICODE);
    exit;
}

$me = member_current();
$username = $me['username'];
$action = isset($_REQUEST['action']) ? (string) $_REQUEST['action'] : '';
$limit = 20;

try {
    $db = new Database();
    $conn = $db->getConnection();

    switch ($action) {

        case 'my_summary': {
            $stmt = $conn->prepare(
                "SELECT COUNT(*) AS total,
                        SUM(CASE WHEN book_suscess = 1 THEN 1 ELSE 0 END) AS confirmed,
                        SUM(CASE WHEN book_suscess = 0 THEN 1 ELSE 0 END) AS pending
                 FROM log_edit WHERE tripitaka91_user = :username"
            );
            $stmt->bindValue(':username', $username, PDO::PARAM_STR);
            $stmt->execute();
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            $stmtD = $conn->prepare(
                "SELECT COUNT(*) AS pending_disputes FROM log_edit_dispute
                 WHERE tripitaka91_user = :username AND status = 0"
            );
            $stmtD->bindValue(':username', $username, PDO::PARAM_STR);
            $stmtD->execute();
            $rowD = $stmtD->fetch(PDO::FETCH_ASSOC);

            echo json_encode([
                'success' => true,
                'data' => [
                    'total' => (int) $row['total'],
                    'confirmed' => (int) $row['confirmed'],
                    'pending' => (int) $row['pending'],
                    'pending_disputes' => (int) $rowD['pending_disputes'],
                ],
            ], JSON_UNESCAPED_UNICODE);
            break;
        }

        case 'system_summary': {
            $stmt = $conn->query(
                "SELECT COUNT(*) AS total,
                        SUM(CASE WHEN book_suscess = 1 THEN 1 ELSE 0 END) AS confirmed,
                        SUM(CASE WHEN book_suscess = 0 THEN 1 ELSE 0 END) AS pending
                 FROM log_edit"
            );
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            $stmtD = $conn->query("SELECT COUNT(*) AS pending_disputes FROM log_edit_dispute WHERE status = 0");
            $rowD = $stmtD->fetch(PDO::FETCH_ASSOC);

            echo json_encode([
                'success' => true,
                'data' => [
                    'total' => (int) $row['total'],
                    'confirmed' => (int) $row['confirmed'],
                    'pending' => (int) $row['pending'],
                    'pending_disputes' => (int) $rowD['pending_disputes'],
                ],
            ], JSON_UNESCAPED_UNICODE);
            break;
        }

        case 'my_list': {
            $status = isset($_GET['status']) ? (string) $_GET['status'] : 'all';
            $page = isset($_GET['page']) && (int) $_GET['page'] > 0 ? (int) $_GET['page'] : 1;
            $offset = ($page - 1) * $limit;

            $where = 'WHERE tripitaka91_user = :username';
            if ($status === 'pending') {
                $where .= ' AND book_suscess = 0';
            } elseif ($status === 'confirmed') {
                $where .= ' AND book_suscess = 1';
            }

            $stmtCount = $conn->prepare("SELECT COUNT(*) AS total FROM log_edit $where");
            $stmtCount->bindValue(':username', $username, PDO::PARAM_STR);
            $stmtCount->execute();
            $total = (int) $stmtCount->fetch(PDO::FETCH_ASSOC)['total'];

            $stmt = $conn->prepare(
                "SELECT tripitaka91_book, tripitaka91_page, tripitaka91_line,
                        tripitaka91_wordincorrect, tripitaka91_wordcorrect, tripitaka91_wordcorrectcomment,
                        tripitaka91_dateadd, book_confirm, book_suscess
                 FROM log_edit
                 $where
                 ORDER BY tripitaka91_dateadd DESC
                 LIMIT :limit OFFSET :offset"
            );
            $stmt->bindValue(':username', $username, PDO::PARAM_STR);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo json_encode([
                'success' => true,
                'data' => $rows,
                'page' => $page,
                'total' => $total,
                'has_more' => $offset + count($rows) < $total,
            ], JSON_UNESCAPED_UNICODE);
            break;
        }

        case 'my_disputes': {
            $page = isset($_GET['page']) && (int) $_GET['page'] > 0 ? (int) $_GET['page'] : 1;
            $offset = ($page - 1) * $limit;

            $stmtCount = $conn->prepare("SELECT COUNT(*) AS total FROM log_edit_dispute WHERE tripitaka91_user = :username");
            $stmtCount->bindValue(':username', $username, PDO::PARAM_STR);
            $stmtCount->execute();
            $total = (int) $stmtCount->fetch(PDO::FETCH_ASSOC)['total'];

            $stmt = $conn->prepare(
                "SELECT tripitaka91_book, tripitaka91_page, tripitaka91_line, tripitaka91_comment,
                        tripitaka91_dateadd, status, resolved_at
                 FROM log_edit_dispute
                 WHERE tripitaka91_user = :username
                 ORDER BY tripitaka91_dateadd DESC
                 LIMIT :limit OFFSET :offset"
            );
            $stmt->bindValue(':username', $username, PDO::PARAM_STR);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo json_encode([
                'success' => true,
                'data' => $rows,
                'page' => $page,
                'total' => $total,
                'has_more' => $offset + count($rows) < $total,
            ], JSON_UNESCAPED_UNICODE);
            break;
        }

        case 'submit_dispute': {
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                http_response_code(405);
                echo json_encode(['success' => false, 'message' => 'Method not allowed'], JSON_UNESCAPED_UNICODE);
                break;
            }
            if (!member_csrf_check($_POST['csrf_token'] ?? null)) {
                http_response_code(403);
                echo json_encode(['success' => false, 'message' => 'เซสชันหมดอายุ กรุณาโหลดหน้าใหม่'], JSON_UNESCAPED_UNICODE);
                break;
            }

            $bookid = isset($_POST['book']) ? (int) $_POST['book'] : 0;
            $bookpage = isset($_POST['page']) ? (int) $_POST['page'] : 0;
            $bookline = isset($_POST['line']) ? (int) $_POST['line'] : 0;
            $comment = trim((string) ($_POST['comment'] ?? ''));

            if ($bookid <= 0 || $bookpage <= 0 || $bookline <= 0 || $comment === '') {
                echo json_encode(['success' => false, 'message' => 'กรุณากรอกข้อมูลให้ครบถ้วน'], JSON_UNESCAPED_UNICODE);
                break;
            }

            $conn->beginTransaction();

            // ต้องเป็นรายการที่ถูกแก้ไขแล้วเท่านั้นจึงจะแจ้งข้อโต้แย้งได้
            $stmtCheck = $conn->prepare(
                "SELECT MAX(book_suscess) AS booksuscess FROM log_edit
                 WHERE tripitaka91_book = :bookid AND tripitaka91_page = :bookpage AND tripitaka91_line = :bookline"
            );
            $stmtCheck->bindValue(':bookid', $bookid, PDO::PARAM_INT);
            $stmtCheck->bindValue(':bookpage', $bookpage, PDO::PARAM_INT);
            $stmtCheck->bindValue(':bookline', $bookline, PDO::PARAM_INT);
            $stmtCheck->execute();
            $checkResult = $stmtCheck->fetch(PDO::FETCH_ASSOC);

            if (!$checkResult || (int) $checkResult['booksuscess'] !== 1) {
                $conn->rollBack();
                echo json_encode(['success' => false, 'message' => 'รายการนี้ยังไม่ได้ถูกแก้ไข ไม่สามารถแจ้งข้อโต้แย้งได้'], JSON_UNESCAPED_UNICODE);
                break;
            }

            // กันแจ้งซ้ำขณะที่ยังรอการตรวจสอบจากคนเดิม
            $stmtDup = $conn->prepare(
                "SELECT id FROM log_edit_dispute
                 WHERE tripitaka91_book = :bookid AND tripitaka91_page = :bookpage AND tripitaka91_line = :bookline
                 AND tripitaka91_user = :username AND status = 0"
            );
            $stmtDup->bindValue(':bookid', $bookid, PDO::PARAM_INT);
            $stmtDup->bindValue(':bookpage', $bookpage, PDO::PARAM_INT);
            $stmtDup->bindValue(':bookline', $bookline, PDO::PARAM_INT);
            $stmtDup->bindValue(':username', $username, PDO::PARAM_STR);
            $stmtDup->execute();

            if ($stmtDup->fetch(PDO::FETCH_ASSOC)) {
                $conn->rollBack();
                echo json_encode(['success' => false, 'message' => 'คุณได้แจ้งข้อโต้แย้งนี้ไว้แล้ว กำลังรอการตรวจสอบ'], JSON_UNESCAPED_UNICODE);
                break;
            }

            $clientIp = $_SERVER['REMOTE_ADDR'] ?? '';

            $stmtInsert = $conn->prepare(
                "INSERT INTO log_edit_dispute
                    (tripitaka91_book, tripitaka91_page, tripitaka91_line, tripitaka91_user, tripitaka91_comment, tripitaka91_ip)
                 VALUES (:bookid, :bookpage, :bookline, :username, :comment, :ip)"
            );
            $stmtInsert->bindValue(':bookid', $bookid, PDO::PARAM_INT);
            $stmtInsert->bindValue(':bookpage', $bookpage, PDO::PARAM_INT);
            $stmtInsert->bindValue(':bookline', $bookline, PDO::PARAM_INT);
            $stmtInsert->bindValue(':username', $username, PDO::PARAM_STR);
            $stmtInsert->bindValue(':comment', $comment, PDO::PARAM_STR);
            $stmtInsert->bindValue(':ip', $clientIp, PDO::PARAM_STR);
            $stmtInsert->execute();

            $conn->commit();

            echo json_encode(['success' => true, 'message' => 'แจ้งข้อโต้แย้งเรียบร้อยแล้ว รอการตรวจสอบจากผู้ดูแลระบบ'], JSON_UNESCAPED_UNICODE);
            break;
        }

        case 'speech_my_summary': {
            $stmt = $conn->prepare(
                "SELECT COUNT(*) AS total,
                        SUM(CASE WHEN speak_suscess = 1 THEN 1 ELSE 0 END) AS confirmed,
                        SUM(CASE WHEN speak_suscess = 0 THEN 1 ELSE 0 END) AS pending
                 FROM log_speak WHERE username = :username"
            );
            $stmt->bindValue(':username', $username, PDO::PARAM_STR);
            $stmt->execute();
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            echo json_encode([
                'success' => true,
                'data' => [
                    'total' => (int) $row['total'],
                    'confirmed' => (int) $row['confirmed'],
                    'pending' => (int) $row['pending'],
                ],
            ], JSON_UNESCAPED_UNICODE);
            break;
        }

        case 'speech_system_summary': {
            $stmt = $conn->query(
                "SELECT COUNT(*) AS total,
                        SUM(CASE WHEN speak_suscess = 1 THEN 1 ELSE 0 END) AS confirmed,
                        SUM(CASE WHEN speak_suscess = 0 THEN 1 ELSE 0 END) AS pending
                 FROM log_speak"
            );
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            echo json_encode([
                'success' => true,
                'data' => [
                    'total' => (int) $row['total'],
                    'confirmed' => (int) $row['confirmed'],
                    'pending' => (int) $row['pending'],
                ],
            ], JSON_UNESCAPED_UNICODE);
            break;
        }

        case 'speech_my_list': {
            $status = isset($_GET['status']) ? (string) $_GET['status'] : 'all';
            $page = isset($_GET['page']) && (int) $_GET['page'] > 0 ? (int) $_GET['page'] : 1;
            $offset = ($page - 1) * $limit;

            $where = 'WHERE username = :username';
            if ($status === 'pending') {
                $where .= ' AND speak_suscess = 0';
            } elseif ($status === 'confirmed') {
                $where .= ' AND speak_suscess = 1';
            }

            $stmtCount = $conn->prepare("SELECT COUNT(*) AS total FROM log_speak $where");
            $stmtCount->bindValue(':username', $username, PDO::PARAM_STR);
            $stmtCount->execute();
            $total = (int) $stmtCount->fetch(PDO::FETCH_ASSOC)['total'];

            $stmt = $conn->prepare(
                "SELECT words, words_speak, words_comfirm, comments, words_dataaddedit, speak_suscess
                 FROM log_speak
                 $where
                 ORDER BY words_dataaddedit DESC
                 LIMIT :limit OFFSET :offset"
            );
            $stmt->bindValue(':username', $username, PDO::PARAM_STR);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo json_encode([
                'success' => true,
                'data' => $rows,
                'page' => $page,
                'total' => $total,
                'has_more' => $offset + count($rows) < $total,
            ], JSON_UNESCAPED_UNICODE);
            break;
        }

        case 'submit_speech': {
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                http_response_code(405);
                echo json_encode(['success' => false, 'message' => 'Method not allowed'], JSON_UNESCAPED_UNICODE);
                break;
            }
            if (!member_csrf_check($_POST['csrf_token'] ?? null)) {
                http_response_code(403);
                echo json_encode(['success' => false, 'message' => 'เซสชันหมดอายุ กรุณาโหลดหน้าใหม่'], JSON_UNESCAPED_UNICODE);
                break;
            }

            $words = trim((string) ($_POST['words'] ?? ''));
            $wordsSpeak = trim((string) ($_POST['words_speak'] ?? ''));
            $comments = trim((string) ($_POST['comments'] ?? ''));
            if ($comments === '') {
                $comments = '-';
            }

            if ($words === '' || $wordsSpeak === '') {
                echo json_encode(['success' => false, 'message' => 'กรุณากรอกคำต้นฉบับและคำอ่านให้ครบถ้วน'], JSON_UNESCAPED_UNICODE);
                break;
            }

            $stmtCheck = $conn->prepare('SELECT username FROM log_speak WHERE words = :words');
            $stmtCheck->bindValue(':words', $words, PDO::PARAM_STR);
            $stmtCheck->execute();
            $existing = $stmtCheck->fetch(PDO::FETCH_ASSOC);

            if ($existing) {
                $existingUser = (string) $existing['username'];
                $message = $existingUser === $username
                    ? "คุณได้แจ้งคำว่า \"$words\" ไว้แล้ว กำลังรอดำเนินการ"
                    : "คำว่า \"$words\" มีผู้แจ้งการอ่านออกเสียงไว้แล้ว";
                echo json_encode(['success' => false, 'message' => $message], JSON_UNESCAPED_UNICODE);
                break;
            }

            $wordsLength = strlen($words);

            try {
                $stmtInsert = $conn->prepare(
                    'INSERT INTO log_speak (words, words_speak, words_length, words_comfirm, comments, username)
                     VALUES (:words, :words_speak, :words_length, 0, :comments, :username)'
                );
                $stmtInsert->bindValue(':words', $words, PDO::PARAM_STR);
                $stmtInsert->bindValue(':words_speak', $wordsSpeak, PDO::PARAM_STR);
                $stmtInsert->bindValue(':words_length', $wordsLength, PDO::PARAM_INT);
                $stmtInsert->bindValue(':comments', $comments, PDO::PARAM_STR);
                $stmtInsert->bindValue(':username', $username, PDO::PARAM_STR);
                $stmtInsert->execute();

                echo json_encode(['success' => true, 'message' => "บันทึกคำว่า \"$words\" เรียบร้อยแล้ว รอการตรวจสอบ"], JSON_UNESCAPED_UNICODE);
            } catch (PDOException $e) {
                // words เป็น PRIMARY KEY — ถ้ามีคนอื่นแจ้งคำเดียวกันแทรกเข้ามาระหว่าง
                // SELECT กับ INSERT นี้ (race) จะชนกันตรงนี้ แปลงเป็นข้อความที่เข้าใจง่าย
                // แทนที่จะโยน error ทั่วไปออกไป
                if ($e->getCode() === '23000') {
                    echo json_encode(['success' => false, 'message' => "คำว่า \"$words\" มีผู้แจ้งการอ่านออกเสียงไว้แล้ว"], JSON_UNESCAPED_UNICODE);
                } else {
                    throw $e;
                }
            }
            break;
        }

        default:
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'ไม่รู้จักคำสั่งนี้'], JSON_UNESCAPED_UNICODE);
    }
} catch (Exception $e) {
    if (isset($conn) && $conn->inTransaction()) {
        $conn->rollBack();
    }
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'เกิดข้อผิดพลาด: ' . $e->getMessage()], JSON_UNESCAPED_UNICODE);
}
