<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {
    $webconfig = new WebsiteConfig();
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $user = isset($_POST["username"]) ? $_POST["username"] : '';  
    $page = isset($_POST["page"]) && $_POST["page"] > 0 ? $_POST["page"] : 1;
    $opt = isset($_POST["opt"]) ? $_POST["opt"] : '0';
    $limit = 50;
    $offset = ($page - 1) * $limit;
    
    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    
    }
    $db = new Database();
    $conn = $db->getConnection();
    $local_timezone = 'Asia/Bangkok';
    
    if (($opt == '0') || ($opt == '1')) {    
        $sql = "
            SELECT
                ls.*,
                CONVERT_TZ(ls.words_dataaddedit, '+00:00', :timezone) AS words_dataaddedit_local            
            FROM
                log_speak ls
            LEFT JOIN
                log_speak_confirm lsc ON ls.words = lsc.words 
                AND lsc.tripitaka91_user = :user";

        if ($opt == '0') {
            $sql .= " WHERE ls.speak_suscess = 0
            AND lsc.tripitaka91_user IS NULL";
        } else {
            $sql .= " WHERE ls.speak_suscess = 0 
            AND lsc.tripitaka91_user IS NOT NULL";
        }

        $sql .= " LIMIT
                    :limit OFFSET :offset";

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);  
        $stmt->bindValue(':user', $user, PDO::PARAM_STR); // เพิ่มการผูกค่าพารามิเตอร์ :user  
        $stmt->bindParam(':timezone', $local_timezone); // ต้องการแปลงเวลา
        $stmt->execute();

        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($result) {
            echo json_encode([
                'success' => true,
                'message' => $result
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'ไม่พบข้อมูล'
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        }
    }else{
        $sql = "
            SELECT
                ls.*,
                CONVERT_TZ(ls.words_dataaddedit, '+00:00', :timezone) AS words_dataaddedit_local            
            FROM
                log_speak ls
            LEFT JOIN
                log_speak_confirm lsc ON ls.words = lsc.words 
                AND lsc.tripitaka91_user = :user";

        if ($opt == '0') {
            $sql .= " WHERE lsc.tripitaka91_user IS NULL";
        } else {
            $sql .= " WHERE lsc.tripitaka91_user IS NOT NULL";
        }

        $sql .= " ORDER BY speak_suscess"; // เรียงลำดับข้อมูลตามฟิลด์ speak_suscess
        $sql .= " LIMIT :limit OFFSET :offset";

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);  
        $stmt->bindValue(':user', $user, PDO::PARAM_STR); // เพิ่มการผูกค่าพารามิเตอร์ :user  
        $stmt->bindParam(':timezone', $local_timezone); // ต้องการแปลงเวลา
        $stmt->execute();

        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($result) {
            echo json_encode([
                'success' => true,
                'message' => $result
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'ไม่พบข้อมูล'
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        }
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
