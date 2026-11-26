<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {
    $webconfig = new WebsiteConfig();
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $page = isset($_POST["page"]) && $_POST["page"] > 0 ? $_POST["page"] : 1;
    $opt = isset($_POST["opt"]) ? $_POST["opt"] : '0';
    $limit = 50;
    $offset = ($page - 1) * $limit;

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    $db = new Database();
    $conn = $db->getConnection();
    // ป้องกัน GROUP_CONCAT ตัดข้อความทิ้งแบบเงียบๆ เมื่อความเห็นยาวหรือมีหลายคนแจ้ง
    $conn->exec("SET SESSION group_concat_max_len = 20000");

    $sql = "
        SELECT
            d.tripitaka91_book,
            d.tripitaka91_page,
            d.tripitaka91_line,
            GROUP_CONCAT(DISTINCT d.tripitaka91_user) AS users,
            GROUP_CONCAT(d.tripitaka91_comment SEPARATOR ' || ') AS comments,
            COUNT(*) AS dispute_count,
            MAX(d.tripitaka91_dateadd) AS dateadd,
            bl.book_detail AS current_book_detail
        FROM
            log_edit_dispute d
        LEFT JOIN
            tripitaka91_91book_line bl ON bl.book_id = d.tripitaka91_book
            AND bl.book_pages = d.tripitaka91_page
            AND bl.book_lines = d.tripitaka91_line";

    if ($opt == '0') {
        $sql .= " WHERE d.status = 0";
    } else {
        $sql .= " WHERE d.status IN (1, 2)";
    }

    $sql .= " GROUP BY
            d.tripitaka91_book, d.tripitaka91_page, d.tripitaka91_line
            ORDER BY MAX(d.tripitaka91_dateadd) DESC
            LIMIT :limit OFFSET :offset";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();

    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($result) {
        echo json_encode([
            'success' => true,
            'message' => $result
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'ไม่พบข้อมูล'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
