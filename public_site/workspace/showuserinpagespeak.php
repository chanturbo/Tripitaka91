<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

try {
    $webconfig = new WebsiteConfig();

    $token = isset($_POST["token"]) ? $_POST["token"] : '';    
    $words = isset($_POST["words"]) ? $_POST["words"] : '';


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
    $local_timezone = 'Asia/Bangkok';
    
    if (!empty($words)) {
        $sql = "SELECT users.*, CONVERT_TZ(log_speak_confirm.tripitaka91_dateconfirm, '+00:00', :timezone) AS tripitaka91_dateconfirm_local
        FROM log_speak_confirm 
        INNER JOIN users ON log_speak_confirm.tripitaka91_user = users.username 
        WHERE log_speak_confirm.words = :words
        ORDER BY log_speak_confirm.tripitaka91_dateconfirm";

        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':words', $words, PDO::PARAM_STR);
        $stmt->bindParam(':timezone', $local_timezone, PDO::PARAM_STR);
        $stmt->execute();

                
        $resultUser = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (!empty($resultUser)) {
            echo json_encode([
                'success' => true,
                'message' => $resultUser
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'ไม่พบข้อมูล',
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        }

    } else {
        echo json_encode([
            'success' => false,
            'message' => 'กรุณาเลือกข้อมูล words',
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
