<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {
    $webconfig = new WebsiteConfig();
    $db = new Database();
    $conn = $db->getConnection();

    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : '';
    $action = isset($_POST["action"]) ? $_POST["action"] : '';
    $keyword = isset($_POST["keyword"]) ? $_POST["keyword"] : '';

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    if ($action == 'save') {
        // ตรวจสอบว่ามีข้อมูลในตาราง log_history แล้วหรือไม่
        $check_sql = "SELECT * FROM log_history_m WHERE username = :username AND keyword = :keyword";
        $check_stmt = $conn->prepare($check_sql);
        $check_stmt->bindParam(':username', $username);
        $check_stmt->bindParam(':keyword', $keyword);
        $check_stmt->execute();

        if ($check_stmt->rowCount() > 0) {
            // มีข้อมูลอยู่แล้ว ดำเนินการแก้ไขข้อมูล
            $update_sql = "UPDATE log_history_m SET count = count + 1 WHERE username = :username AND keyword = :keyword";
            $update_stmt = $conn->prepare($update_sql);
            $update_stmt->bindParam(':username', $username);
            $update_stmt->bindParam(':keyword', $keyword);

            if ($update_stmt->execute()) {
                echo json_encode([
                    'success' => true,
                    'message' => 'บันทึกประวัติการค้นหาสำเร็จ'
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'เกิดข้อผิดพลาดในการบันทึกประวัติการค้นหา'
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            }
        } else {
            // ไม่มีข้อมูล ดำเนินการบันทึกข้อมูลใหม่
            $insert_sql = "INSERT INTO log_history_m (username, keyword, count)                     
                    VALUES (:username, :keyword, 1)";
                    //VALUES (:username, :keyword, 1, CONVERT_TZ(NOW(), 'UTC', 'Asia/Bangkok'))";
            $insert_stmt = $conn->prepare($insert_sql);
            $insert_stmt->bindParam(':username', $username);
            $insert_stmt->bindParam(':keyword', $keyword);

            if ($insert_stmt->execute()) {
                echo json_encode([
                    'success' => true,
                    'message' => 'บันทึกประวัติการค้นหาสำเร็จ'
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'เกิดข้อผิดพลาดในการบันทึกประวัติการค้นหา'
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            }
        }
    } elseif ($action == 'read') {
        if ($username == 'guest'){
            // ดึงข้อมูลจากตาราง log_history
            $selectQuery = "SELECT * FROM log_history WHERE username = :username ORDER BY timestamp DESC LIMIT 100";
        }else{
            $selectQuery = "SELECT * FROM log_history_m WHERE username = :username ORDER BY timestamp DESC LIMIT 100";    
        }
        // เตรียมพารามิเตอร์สำหรับ SQL statement
        $selectParams = array(':username' => $username);

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
                        'keyword' => str_replace("%", " ", $row['keyword']),
                        'count' => $row['count'],
                        'timestamp' => $row['timestamp']
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
            'message' => 'Invalid action.'
        ], JSON_UNESCAPED_UNICODE);
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'เกิดข้อผิดพลาด: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
