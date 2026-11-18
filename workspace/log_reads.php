<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

// ตรวจสอบว่าเป็นการเรียก API ด้วยเมธอด POST

try {
    $webconfig = new WebsiteConfig();
    $db = new Database(); // สร้างอ็อบเจกต์ Database
    $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO

    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $action = isset($_POST["action"]) ? $_POST["action"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : ''; // เพิ่มบรรทัดนี้
    $book_last_access = isset($_POST["book_last_access"]) ? $_POST["book_last_access"] : '';
    $page_last_access = isset($_POST["page_last_access"]) ? $_POST["page_last_access"] : '';    

    // ตรวจสอบความถูกต้องของ Token ก่อนดำเนินการต่อไป
    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }
    if ($username == 'guest'){
        $username = $_SERVER['HTTP_X_FORWARDED_FOR'];
    }
    if ($action == 'save') {
        // บันทึกข้อมูลลงในตาราง log_reads    
        // ตรวจสอบว่ามีข้อมูลที่ส่งมาหรือไม่
        if (!empty($username) && !empty($book_last_access) && !empty($page_last_access)) {

            // ตรวจสอบว่ามีข้อมูลสำหรับ username และ book_last_access นี้ในตาราง log_reads หรือไม่
            $check_sql = "SELECT * FROM log_reads WHERE username = :username AND book_last_access = :book_last_access";
            $check_stmt = $conn->prepare($check_sql);
            $check_stmt->bindParam(':username', $username);
            $check_stmt->bindParam(':book_last_access', $book_last_access);
            $check_stmt->execute();

            if ($check_stmt->rowCount() > 0) {
                // มีข้อมูลอยู่แล้ว ดำเนินการแก้ไขข้อมูล
                $update_sql = "UPDATE log_reads SET page_last_access = :page_last_access, time_last_access = CONVERT_TZ(NOW(), 'UTC', 'Asia/Bangkok') WHERE username = :username AND book_last_access = :book_last_access";
                $update_stmt = $conn->prepare($update_sql);
                $update_stmt->bindParam(':username', $username);
                $update_stmt->bindParam(':book_last_access', $book_last_access);
                $update_stmt->bindParam(':page_last_access', $page_last_access);

                if ($update_stmt->execute()) {
                    echo json_encode([
                        'success' => true,
                        'message' => 'บันทึกข้อมูลสำเร็จ'
                    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                } else {
                    echo json_encode([
                        'success' => false,
                        'message' => 'เกิดข้อผิดพลาดในการบันทึกข้อมูล'
                    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                }
            } else {
                // ไม่มีข้อมูล ดำเนินการบันทึกข้อมูลใหม่
                $insert_sql = "INSERT INTO log_reads (username, book_last_access, page_last_access, time_last_access) 
                                VALUES (:username, :book_last_access, :page_last_access, CONVERT_TZ(NOW(), 'UTC', 'Asia/Bangkok'))";
                $insert_stmt = $conn->prepare($insert_sql);
                $insert_stmt->bindParam(':username', $username);
                $insert_stmt->bindParam(':book_last_access', $book_last_access);
                $insert_stmt->bindParam(':page_last_access', $page_last_access);

                if ($insert_stmt->execute()) {
                    echo json_encode([
                        'success' => true,
                        'message' => 'บันทึกข้อมูลสำเร็จ'
                    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                } else {
                    echo json_encode([
                        'success' => false,
                        'message' => 'เกิดข้อผิดพลาดในการบันทึกข้อมูล'
                    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                }
            }
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'ไม่มีข้อมูลที่จะบันทึก'
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        }
    } elseif ($action == 'read') {
        // ดึงข้อมูลจากตาราง log_reads
        $selectQuery = "SELECT * FROM log_reads WHERE username = :username ORDER BY time_last_access";

        // เตรียมพารามิเตอร์สำหรับ SQL statement
        $selectParams = array(
            ':username' => $username
        );

        // ทำการเตรียมคำสั่ง SQL
        $stmt = $conn->prepare($selectQuery);

        // ทำการ execute คำสั่ง SQL พร้อมกับพารามิเตอร์
        if ($stmt->execute($selectParams)) {
            // ดึงข้อมูลที่ได้จากการ query
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);    

            if ($result) {
                $responseData = array();
                foreach ($result as $row) {
                    $responseData[] = array(
                        'username' => $row['username'],
                        'time_last_access' => $row['time_last_access'],
                        'book_last_access' => $row['book_last_access'],
                        'page_last_access' => $row['page_last_access']
                    );
                }

                echo json_encode([
                    'success' => true,
                    'message' => 'พบข้อมูล',
                    'data' => $responseData
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'ไม่พบข้อมูล'
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            }
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'เกิดข้อผิดพลาดในการดึงข้อมูล'
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        }
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Action ไม่ถูกต้อง'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'เกิดข้อผิดพลาด: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
