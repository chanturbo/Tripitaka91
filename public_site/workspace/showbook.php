<?php

// กำหนด header ให้รับและส่งข้อมูลในรูปแบบ JSON
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

try {
    $webconfig = new WebsiteConfig();
    $bookid = isset($_POST["bookid"]) ? $_POST["bookid"] : '';
    $pageid = isset($_POST["pageid"]) ? $_POST["pageid"] : '';
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    
    //ตรวจสอบความถูกต้องของ Token ก่อนดำเนินการต่อ
    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    $db = new Database(); // สร้างอ็อบเจกต์ Database
    $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO
    
    if (($bookid != '') && ($pageid != '')){
        if ($pageid == '0'){
            $bookid = 0;
            $pageid = 1;
             $sql = "SELECT * FROM tripitaka91_91book_line 
                    WHERE book_id = :book_id AND book_pages = :book_pages
                    ORDER BY book_line";
        } else {
            $sql = "SELECT * FROM tripitaka91_91book_line 
                    WHERE book_id = :book_id AND book_pages = :book_pages
                    ORDER BY book_line";
        }

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':book_id', $bookid, PDO::PARAM_INT);
        $stmt->bindValue(':book_pages', $pageid, PDO::PARAM_INT);
    }

    $stmt->execute();

    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($result) {
        echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            'error' => 'ไม่พบข้อมูล'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }

} catch (Exception $e) {
    // จัดการข้อผิดพลาดที่เกิดขึ้นจากการเชื่อมต่อหรือการประมวลผล SQL
    echo json_encode([
        'error' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
