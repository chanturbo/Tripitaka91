<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");

try {
    $webconfig = new WebsiteConfig();

    $db = new Database();
    $conn = $db->getConnection();

    for ($bookid = 1; $bookid <= 91; $bookid++) {
        // กำหนด header สำหรับการดาวน์โหลดไฟล์
        header('Content-Disposition: attachment; filename="output-' . $bookid . '.json"');
        header('Content-Type: application/json; charset=utf-8'); 

        // ดึงข้อมูล book_detail จาก database
        $sql_get_details = "SELECT book_detail 
                            FROM tripitaka91_91book_line 
                            WHERE book_id = :bookid";
        $stmt_get_details = $conn->prepare($sql_get_details);
        $stmt_get_details->bindParam(':bookid', $bookid, PDO::PARAM_INT);
        $stmt_get_details->execute();
        $rows = $stmt_get_details->fetchAll(PDO::FETCH_ASSOC);

        if ($rows) {
            $filtered_words = [];

            // แปลงคำใน book_detail เป็นคำแยก
            foreach ($rows as $row) {
                $words = explode(' ', $row['book_detail']); // แยกคำโดยช่องว่าง
                foreach ($words as $word) {
                    // ตรวจสอบว่าคำมี 'ฺ' หรือ 'ํ'
                    if (strpos($word, 'ฺ') !== false || strpos($word, 'ํ') !== false) {
                        $filtered_words[] = [
                            'word' => $word                            
                        ];
                    }
                }
            }

            // เขียนข้อมูลลงในไฟล์ json
            if (!empty($filtered_words)) {
                $file_path = 'output-' . $bookid . '.json'; // กำหนดชื่อไฟล์
                $file_content = json_encode($filtered_words, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
                file_put_contents($file_path, $file_content); // บันทึกข้อมูลลงไฟล์

                // ส่งออกไฟล์ json สำหรับดาวน์โหลด
                echo $file_content; 
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'ไม่พบคำที่มี "ฺ" หรือ "ํ"'
                ], JSON_UNESCAPED_UNICODE);
            }
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'ไม่พบข้อมูล book_detail ใน book_id ที่ระบุ'
            ], JSON_UNESCAPED_UNICODE);
        }
    } 
} catch (Exception $e) {
    echo json_encode([
        'error' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>