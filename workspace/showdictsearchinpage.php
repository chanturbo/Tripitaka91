<?php

require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

function sanitizeString($str) {
    // แปลงอักขระไม่ถูกต้องไปเป็น UTF-8
    $str = mb_convert_encoding($str, 'UTF-8', 'UTF-8');

    // ตัด tag HTML ออก
    $str = strip_tags($str);

    // แทนที่ "LineNull" ด้วยค่าว่าง
    $str = str_replace('LineNull', '', $str);

    // ตัดช่องว่างที่มากกว่า 1 ให้เหลือเพียง 1 ช่องว่าง
    $str = preg_replace('/\s+/', ' ', $str);

    // แทนที่ Tab ด้วย 1 ช่องว่าง
    $str = str_replace("\t", ' ', $str);

    return $str;
}

try {
    $webconfig = new WebsiteConfig();
    $keywords = isset($_POST["wordsearch"]) ? explode(',', $_POST["wordsearch"]) : [];
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : 'guest';
        
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

    if (!empty($keywords)) {        
        $keywords = array_map('trim', $keywords);        
        
        $cleanedKeywords = array_map(function($keyword) {
            return $keyword;
        }, $keywords);
        
        $keywordsString = "'" . implode("','", $cleanedKeywords) . "'";
        $sql = "SELECT buddic_word, buddic_detail FROM tripitaka91_dict WHERE buddic_word IN ({$keywordsString})";
        
        $stmt = $conn->prepare($sql);
        $stmt->execute();
                
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $response = array();
        foreach ($result as $row_title) {            
            $cleanedString = sanitizeString($row_title['buddic_word'] . "|" . $row_title['buddic_detail']);
            $response[] = $cleanedString;
        }        
        
        if (!empty($response)) {
            echo json_encode([
                'success' => true,
                'message' => $response
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
            'message' => 'กรุณาป้อนข้อมูลก่อน'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);     
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
