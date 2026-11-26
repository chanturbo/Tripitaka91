<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {
    $webconfig = new WebsiteConfig();
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $user = isset($_POST["username"]) ? $_POST["username"] : '';  
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

    if (($opt == '0') || ($opt == '1')) {    
        $sql = "
            SELECT
                le.tripitaka91_book,
                le.tripitaka91_page,
                le.tripitaka91_line,
                GROUP_CONCAT(DISTINCT le.book_detail_old) AS detail_old,
                GROUP_CONCAT(DISTINCT le.book_detail_new) AS detail_new,
                GROUP_CONCAT(DISTINCT le.tripitaka91_wordincorrect) AS wordincorrect,
                GROUP_CONCAT(DISTINCT le.tripitaka91_wordcorrect) AS wordcorrect,
                GROUP_CONCAT(DISTINCT le.tripitaka91_wordcorrectcomment) AS wordcorrectcomment,
                MAX(le.tripitaka91_wordsum) AS wordsum,
                GROUP_CONCAT(DISTINCT le.tripitaka91_user) AS users,
                MAX(le.tripitaka91_dateadd) AS dateadd,
                MAX(le.tripitaka91_dateadd1) AS dateadd1,
                MAX(le.tripitaka91_dateedit) AS dateedit,
                MAX(le.tripitaka91_dateedit1) AS dateedit1,
                MAX(le.tripitaka91_ip) AS ip,
                MAX(le.book_confirm) AS bookconfirm,
                MAX(le.book_suscess) AS booksuscess
            FROM
                log_edit le
            LEFT JOIN
                log_edit_confirm lec ON le.tripitaka91_book = lec.tripitaka91_book
                AND le.tripitaka91_page = lec.tripitaka91_page
                AND le.tripitaka91_line = lec.tripitaka91_line
                AND lec.tripitaka91_user = :user";

            if ($opt == '0'){
                $sql .= " WHERE
                    le.book_suscess = 0
                    AND lec.tripitaka91_user IS NULL";
            }else{
                $sql .= " WHERE
                    le.book_suscess = 0
                    AND lec.tripitaka91_user IS NOT NULL";
            }

            $sql .= " GROUP BY
                    le.tripitaka91_book,
                    le.tripitaka91_page,
                    le.tripitaka91_line
                    ORDER BY bookconfirm DESC,le.tripitaka91_book,le.tripitaka91_page
                LIMIT
                    :limit OFFSET :offset";

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);    
        $stmt->bindValue(':user', $user, PDO::PARAM_STR); // เพิ่มการผูกค่าพารามิเตอร์ :user
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
    }else{
        $sql = "
            SELECT
                le.tripitaka91_book,
                le.tripitaka91_page,
                le.tripitaka91_line,
                GROUP_CONCAT(DISTINCT le.book_detail_old) AS detail_old,
                GROUP_CONCAT(DISTINCT le.book_detail_new) AS detail_new,
                GROUP_CONCAT(DISTINCT le.tripitaka91_wordincorrect) AS wordincorrect,
                GROUP_CONCAT(DISTINCT le.tripitaka91_wordcorrect) AS wordcorrect,
                GROUP_CONCAT(DISTINCT le.tripitaka91_wordcorrectcomment) AS wordcorrectcomment,
                MAX(le.tripitaka91_wordsum) AS wordsum,
                GROUP_CONCAT(DISTINCT le.tripitaka91_user) AS users,
                MAX(le.tripitaka91_dateadd) AS dateadd,
                MAX(le.tripitaka91_dateadd1) AS dateadd1,
                MAX(le.tripitaka91_dateedit) AS dateedit,
                MAX(le.tripitaka91_dateedit1) AS dateedit1,
                MAX(le.tripitaka91_ip) AS ip,
                MAX(le.book_confirm) AS bookconfirm,
                MAX(le.book_suscess) AS booksuscess
            FROM
                log_edit le
            LEFT JOIN
                log_edit_confirm lec ON le.tripitaka91_book = lec.tripitaka91_book
                AND le.tripitaka91_page = lec.tripitaka91_page
                AND le.tripitaka91_line = lec.tripitaka91_line
                AND lec.tripitaka91_user = :user";

            if ($opt == '0'){
                $sql .= " WHERE 
                    lec.tripitaka91_user IS NULL";
            }else{
                $sql .= " WHERE 
                    lec.tripitaka91_user IS NOT NULL";
            }

            $sql .= " GROUP BY
                    le.tripitaka91_book,
                    le.tripitaka91_page,
                    le.tripitaka91_line
                    ORDER BY booksuscess";
            $sql .= " LIMIT 
                        :limit OFFSET :offset";                                    

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);    
        $stmt->bindValue(':user', $user, PDO::PARAM_STR); // เพิ่มการผูกค่าพารามิเตอร์ :user
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
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
