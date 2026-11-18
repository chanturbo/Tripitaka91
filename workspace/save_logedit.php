<?
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {
    $webconfig = new WebsiteConfig();
    $db = new Database(); // สร้างอ็อบเจกต์ Database
    $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO
    
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $json_data = isset($_POST["json_data"]) ? $_POST["json_data"] : '';

    // ตรวจสอบความถูกต้องของ Token ก่อนดำเนินการต่อ
    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    $data = json_decode($json_data, true);

    // ตรวจสอบว่าข้อมูลไม่ว่างเปล่า
    if (empty($data)) {
        echo json_encode([
            'success' => false,
            'message' => 'ไม่มีข้อมูลที่จะบันทึก'
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    // วนลูปในข้อมูล JSON ที่ได้รับ
    foreach ($data as $record) {
        // ดึงค่าจาก JSON แต่ละเรคอร์ด
        $tripitaka91Book = $record['tripitaka91_book'];
        $tripitaka91Page = $record['tripitaka91_page'];
        $tripitaka91Line = $record['tripitaka91_line'];
        $tripitaka91Detail = $record['book_detail_old']; // เพิ่มการดึงค่า book_detail_old
        $tripitaka91Wordincorrect = $record['tripitaka91_wordincorrect'];
        $tripitaka91Wordcorrect = $record['tripitaka91_wordcorrect'];
        $tripitaka91Wordcorrectcomment = $record['tripitaka91_wordcorrectcomment'];
        $tripitaka91Wordsum = $record['tripitaka91_wordsum'];
        $tripitaka91User = $record['tripitaka91_user'];
        $tripitaka91Dateadd = $record['tripitaka91_dateadd'];
        $tripitaka91Dateadd1 = $record['tripitaka91_dateadd1'];
        $tripitaka91Dateedit = $record['tripitaka91_dateedit'];
        $tripitaka91Dateedit1 = $record['tripitaka91_dateedit1'];
        $tripitaka91Ip = $record['tripitaka91_ip'];
    
        // ทำตามการบันทึกข้อมูลลงในฐานข้อมูล MySQL ต่อไปนี้        
        $stmt = $conn->prepare("
            INSERT INTO log_edit 
            (tripitaka91_book, tripitaka91_page, tripitaka91_line, book_detail_old, tripitaka91_wordincorrect, tripitaka91_wordcorrect, tripitaka91_wordcorrectcomment, tripitaka91_wordsum, tripitaka91_user, tripitaka91_dateadd, tripitaka91_dateadd1, tripitaka91_dateedit, tripitaka91_dateedit1, tripitaka91_ip) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
            tripitaka91_wordincorrect = VALUES(tripitaka91_wordincorrect),
            tripitaka91_wordcorrect = VALUES(tripitaka91_wordcorrect),
            tripitaka91_wordcorrectcomment = VALUES(tripitaka91_wordcorrectcomment),
            tripitaka91_wordsum = VALUES(tripitaka91_wordsum),
            tripitaka91_dateadd = VALUES(tripitaka91_dateadd),
            tripitaka91_dateadd1 = VALUES(tripitaka91_dateadd1),
            tripitaka91_dateedit = VALUES(tripitaka91_dateedit),
            tripitaka91_dateedit1 = VALUES(tripitaka91_dateedit1),
            tripitaka91_ip = VALUES(tripitaka91_ip)
        ");
    
        $stmt->bindParam(1, $tripitaka91Book);
        $stmt->bindParam(2, $tripitaka91Page);
        $stmt->bindParam(3, $tripitaka91Line);
        $stmt->bindParam(4, $tripitaka91Detail); // เพิ่มการ bind ค่าของ tripitaka91Detail
        $stmt->bindParam(5, $tripitaka91Wordincorrect);
        $stmt->bindParam(6, $tripitaka91Wordcorrect);
        $stmt->bindParam(7, $tripitaka91Wordcorrectcomment);
        $stmt->bindParam(8, $tripitaka91Wordsum);
        $stmt->bindParam(9, $tripitaka91User);
        $stmt->bindParam(10, $tripitaka91Dateadd);
        $stmt->bindParam(11, $tripitaka91Dateadd1);
        $stmt->bindParam(12, $tripitaka91Dateedit);
        $stmt->bindParam(13, $tripitaka91Dateedit1);
        $stmt->bindParam(14, $tripitaka91Ip);        
    
        $stmt->execute();
    }    

    // ส่ง JSON response กลับไปที่ Flutter
    echo json_encode([
        'success' => true,
        'message' => 'บันทึกข้อมูลสำเร็จ'
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    // จัดการข้อผิดพลาดที่เกิดขึ้นจากการเชื่อมต่อหรือการประมวลผล SQL
    echo json_encode([
        'success' => false,
        'message' => 'เกิดข้อผิดพลาด: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>