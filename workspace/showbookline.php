<?php

require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

try {
    $webconfig = new WebsiteConfig();
    $bookid = isset($_POST["bookid"]) ? $_POST["bookid"] : '';
    $pageid = isset($_POST["pageid"]) ? $_POST["pageid"] : '';
    $lineid = isset($_POST["lineid"]) ? $_POST["lineid"] : '';
    $token = isset($_POST["token"]) ? $_POST["token"] : '';

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    $db = new Database();
    $conn = $db->getConnection();

    if (($bookid != '') && ($pageid != '') && ($lineid != '')){ // ตรวจสอบว่ามีค่าที่เพิ่มเข้ามาหรือไม่
        if ($pageid == '0'){
            $bookid = 0;
            $pageid = 1;
            $sql = "SELECT book_detail FROM tripitaka91_91book_line 
                    WHERE book_id = :book_id AND book_pages = :book_pages AND book_lines = :book_lines
                    ORDER BY book_line";
        } else {
            $sql = "SELECT book_detail FROM tripitaka91_91book_line 
                    WHERE book_id = :book_id AND book_pages = :book_pages AND book_lines = :book_lines
                    ORDER BY book_line";
        }

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':book_id', $bookid, PDO::PARAM_INT);
        $stmt->bindValue(':book_pages', $pageid, PDO::PARAM_INT);
        $stmt->bindValue(':book_lines', $lineid, PDO::PARAM_INT); // ผูกค่า lineid กับพารามิเตอร์ของ SQL
    }

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
            'error' => 'ไม่พบข้อมูล'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }

} catch (Exception $e) {
    // จัดการข้อผิดพลาดที่เกิดขึ้นจากการเชื่อมต่อหรือการประมวลผล SQL
    echo json_encode([
        'success' => false,
        'error' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
