<?php

require_once 'db_connect.php';
require_once 'websiteconfig.php';
require_once 'create_folder.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

try {
    $webconfig = new WebsiteConfig();
    $token = isset($_POST["token"]) ? $_POST["token"] : '';    
    $bookid = isset($_POST["bookid"]) ? $_POST["bookid"] : '';
    $bookpage = isset($_POST["bookpage"]) ? $_POST["bookpage"] : '';
    $bookline = isset($_POST["bookline"]) ? $_POST["bookline"] : '';
    // print($book_speak);
    // print($wordsearch);

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    if (empty($bookid) || empty($bookpage) || empty($bookline)) {
        echo json_encode([
            'success' => false,
            'message' => 'ไม่พบข้อมูลที่ส่งมา bookid, bookpage, bookline'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้าไม่พบข้อมูล
    }else{    
        $db = new Database();
        $conn = $db->getConnection();
        $conn->beginTransaction(); // เริ่ม Transaction
        
        $sql = "SELECT book_detail_old,book_detail_new FROM log_edit WHERE tripitaka91_book = :bookid AND tripitaka91_page = :bookpage AND tripitaka91_line = :bookline";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':bookid', $bookid, PDO::PARAM_INT);
        $stmt->bindParam(':bookpage', $bookpage, PDO::PARAM_INT);
        $stmt->bindParam(':bookline', $bookline, PDO::PARAM_INT);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            $book_detail_new = $result['book_detail_new'];
            $book_detail_old = $result['book_detail_old'];            
            // ตรงนี้คุณสามารถใช้ตัวแปร $book_detail_new ได้ต่อไปในโค้ดของคุณ
            
            $sql_update = "UPDATE tripitaka91_91book_line 
               SET book_detail = :book_detail_new, 
                   book_detail_old = :book_detail_old
               WHERE book_id = :bookid AND book_pages = :bookpage AND book_lines = :bookline";
            $stmt_update = $conn->prepare($sql_update);
            $stmt_update->bindParam(':book_detail_new', $book_detail_new, PDO::PARAM_STR);
            $stmt_update->bindParam(':book_detail_old', $book_detail_old, PDO::PARAM_STR);
            $stmt_update->bindParam(':bookid', $bookid, PDO::PARAM_INT);
            $stmt_update->bindParam(':bookpage', $bookpage, PDO::PARAM_INT);
            $stmt_update->bindParam(':bookline', $bookline, PDO::PARAM_INT);
            $stmt_update->execute();

            $sql_update_log_edit = "UPDATE log_edit 
                SET book_suscess = 1
                WHERE tripitaka91_book = :bookid AND tripitaka91_page = :bookpage AND tripitaka91_line = :bookline";
            $stmt_update_log_edit = $conn->prepare($sql_update_log_edit);
            $stmt_update_log_edit->bindParam(':bookid', $bookid, PDO::PARAM_INT);
            $stmt_update_log_edit->bindParam(':bookpage', $bookpage, PDO::PARAM_INT);
            $stmt_update_log_edit->bindParam(':bookline', $bookline, PDO::PARAM_INT);
            $stmt_update_log_edit->execute();

            // ดำเนินการลบโฟลเดอร์ Books                
            $rootFolder = 'sounds/books_' . $bookid . '/pages_' . $bookpage;
            if (file_exists($rootFolder) && is_dir($rootFolder)) {
                $folderCreator->deleteMp3Files($rootFolder);
                //echo 'Deleted all MP3 files in the folder: ' . $rootFolder;
            } else {
                //echo 'Folder not found: ' . $rootFolder;
            }

            // ดำเนินการลบโฟลเดอร์ Search                
            $rootFolder = 'sounds/search_' . $bookid . '/pages_' . $bookpage;
            if (file_exists($rootFolder) && is_dir($rootFolder)) {
                $folderCreator->deleteMp3Files($rootFolder);
                //echo 'Deleted all MP3 files in the folder: ' . $rootFolder;
            } else {
                //echo 'Folder not found: ' . $rootFolder;
            }

            // ยืนยัน Transaction
            $conn->commit();                        
            echo json_encode([
                'success' => true,
                'message' => 'บันทึกการแก้ไขข้อมูลเรียบร้อยแล้ว',                
            ], JSON_UNESCAPED_UNICODE);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'ไม่พบข้อมูลใน log_edit ที่ตรงกับเงื่อนไขที่กำหนด'
            ], JSON_UNESCAPED_UNICODE);
        }
        
    }
} catch (Exception $e) {
    // ยกเลิก Transaction ในกรณีที่เกิดข้อผิดพลาด
    $conn->rollBack();
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
