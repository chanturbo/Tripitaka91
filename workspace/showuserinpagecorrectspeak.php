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
        $sql = "SELECT users.*, CONVERT_TZ(log_speak.words_dataaddedit,'+00:00', :timezone) AS tripitaka91_dateadd_local 
        FROM log_speak 
        INNER JOIN users ON log_speak.username = users.username 
        WHERE log_speak.words = :words         
        ORDER BY log_speak.words_dataaddedit";
    
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
            'message' => 'กรุณาป้อนข้อมูล bookid, bookpage และ bookline',
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
