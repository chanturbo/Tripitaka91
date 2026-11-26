<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {
    $webconfig = new WebsiteConfig();
    $token = isset($_GET["token"]) ? $_GET["token"] : '';
    $user = isset($_GET["users"]) ? $_GET["users"] : '';
    $page = isset($_GET["page"]) && $_GET["page"] > 0 ? $_GET["page"] : 1;    
    $opt = isset($_GET["opt"]) ? $_GET["opt"] : '0';
    $limit = 50;
    $offset = ($page - 1) * $limit;
    
    // $tokenkey = $webconfig->getToken();
    // if ($token != $tokenkey) {
    //     echo json_encode([
    //         'success' => false,
    //         'message' => 'Token ไม่ถูกต้อง'
    //     ], JSON_UNESCAPED_UNICODE);
    //     die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    // }

    $db = new Database();
    $conn = $db->getConnection();

    $sql = "
     SELECT * FROM tripitaka91_91title WHERE tripitaka91_title LIKE '%\"%'";
    // UPDATE tripitaka91_91title SET tripitaka91_title = REPLACE(tripitaka91_title, '', '\"') WHERE tripitaka91_title LIKE '%%'";
    
        // if ($opt == '0'){
        //     $sql .= " WHERE
        //         le.book_suscess = 0
        //         AND lec.tripitaka91_user IS NULL";
        // }else{
        //     $sql .= " WHERE
        //         le.book_suscess = 0
        //         AND lec.tripitaka91_user IS NOT NULL";
        // }

        // $sql .= " GROUP BY
        //         le.tripitaka91_book,
        //         le.tripitaka91_page,
        //         le.tripitaka91_line
        //     LIMIT
        //         :limit OFFSET :offset";

    $stmt = $conn->prepare($sql);
    // $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    // $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);    
    // $stmt->bindValue(':user', $user, PDO::PARAM_STR); // เพิ่มการผูกค่าพารามิเตอร์ :user
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
