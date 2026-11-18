<?php

require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

try {
    $webconfig = new WebsiteConfig();    
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $tripitaka91no = isset($_POST["tripitaka91no"]) ? $_POST["tripitaka91no"] : '';
    $tripitaka91code = isset($_POST["tripitaka91code"]) ? $_POST["tripitaka91code"] : '';
    $titledetail = isset($_POST["titledetail"]) ? $_POST["titledetail"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : 'guest';
    $tripitaka91ip = isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : '';

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
    if ($username != 'guest'){

        if ($tripitaka91no != '' && $tripitaka91code != '') {

            // Begin transaction
            $conn->beginTransaction();

            // Check if data exists in log_edit91title table
            $sql_check = "SELECT * FROM log_edit91title WHERE tripitaka91_no = :tripitaka91no AND tripitaka91_code = :tripitaka91code";
            $stmt_check = $conn->prepare($sql_check);
            $stmt_check->bindValue(':tripitaka91no', $tripitaka91no, PDO::PARAM_INT);
            $stmt_check->bindValue(':tripitaka91code', $tripitaka91code, PDO::PARAM_STR);
            $stmt_check->execute();

            if ($stmt_check->rowCount() > 0) {
                // If data exists, update tripitaka91_user and tripitaka91_ip
                $sql = "UPDATE log_edit91title SET tripitaka91_user = :username, tripitaka91_ip = :tripitaka91ip WHERE tripitaka91_no = :tripitaka91no AND tripitaka91_code = :tripitaka91code";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(':username', $username, PDO::PARAM_STR);
                $stmt->bindParam(':tripitaka91ip', $tripitaka91ip, PDO::PARAM_STR);
                $stmt->bindParam(':tripitaka91no', $tripitaka91no, PDO::PARAM_INT);
                $stmt->bindParam(':tripitaka91code', $tripitaka91code, PDO::PARAM_STR);
                $stmt->execute();
            } else {
                // If data doesn't exist, insert new data
                $sql = "INSERT INTO log_edit91title (tripitaka91_no, tripitaka91_code, tripitaka91_user, tripitaka91_ip) VALUES (?, ?, ?, ?)";
                $stmt = $conn->prepare($sql);
                $stmt->bindValue(1, $tripitaka91no, PDO::PARAM_INT);
                $stmt->bindValue(2, $tripitaka91code, PDO::PARAM_STR);
                $stmt->bindValue(3, $username, PDO::PARAM_STR);
                $stmt->bindValue(4, $tripitaka91ip, PDO::PARAM_STR);
                $stmt->execute();
            }



            // Update tripitaka91_title in tripitaka91_91title table
            $sql_update = "UPDATE tripitaka91_91title SET tripitaka91_title = :titledetail WHERE tripitaka91_no = :tripitaka91no AND tripitaka91_code = :tripitaka91code";
            $stmt_update = $conn->prepare($sql_update);
            $stmt_update->bindValue(':titledetail', $titledetail, PDO::PARAM_STR);
            $stmt_update->bindValue(':tripitaka91no', $tripitaka91no, PDO::PARAM_INT);
            $stmt_update->bindValue(':tripitaka91code', $tripitaka91code, PDO::PARAM_STR);
            $stmt_update->execute();

            // Commit the transaction
            $conn->commit();

            if ($stmt_update->rowCount() > 0) {
                echo json_encode([
                    'success' => true,
                    'message' => 'บันทึกข้อมูลเรียบร้อยแล้ว',
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'ไม่พบข้อมูล/โหลดข้อมูลหมดแล้ว',
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            }

        } else {
            echo json_encode([
                'success' => false,
                'message' => 'กรุณาป้อนข้อมูลก่อน'
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);     
        }
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'กรุณาเข้าสู่ระบบก่อน'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);     
    }
} catch (Exception $e) {
    // Rollback the transaction if an error occurs
    $conn->rollBack();

    // Output error message
    echo json_encode([
        'success' => false,
        'message' => 'เกิดข้อผิดพลาดในการบันทึกข้อมูล: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
