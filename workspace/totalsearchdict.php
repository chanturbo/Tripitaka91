<?php
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

try {
    $webconfig = new WebsiteConfig();
    $wordsearch = isset($_POST["wordsearch"]) ? $_POST["wordsearch"] : '';
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : 'guest';

    // ตรวจสอบความถูกต้องของ Token
    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    if ($wordsearch !=''){
        
        $db = new Database();
        $conn = $db->getConnection();

        $sql_history = "SELECT tmp_4 FROM log_history WHERE username = :username AND keyword = :wordsearch ORDER BY timestamp DESC LIMIT 10";
        $stmt_history = $conn->prepare($sql_history);
        $stmt_history->bindParam(':username', $username);
        $stmt_history->bindParam(':wordsearch', $wordsearch);
        $stmt_history->execute();
        $result_history = $stmt_history->fetch(PDO::FETCH_ASSOC);

        if ($result_history && $result_history['tmp_4'] != '0') {
            
            if ($result_history['tmp_4'] != '-1'){
                // $update_sql = "UPDATE log_history SET count = count + 1 WHERE username = :username AND keyword = :wordsearch";
                // $update_stmt = $conn->prepare($update_sql);
                // $update_stmt->bindParam(':username', $username);
                // $update_stmt->bindParam(':wordsearch', $wordsearch);        

                // if ($update_stmt->execute()) {
                //     echo json_encode([
                //         'success' => true,
                //         'message' => 'พบข้อมูลและทำการปรับปรุง',
                //         'total_records' => $result_history['tmp_4']
                //     ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                // }
                echo json_encode([
                    'success' => true,
                    'message' => 'พบข้อมูลและทำการปรับปรุง',
                    'total_records' => $result_history['tmp_4']
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);                
            }else{
                echo json_encode([
                    'success' => true,
                    'message' => 'ไม่พบข้อมูลมีการบันทึกข้อมูลแล้ว',
                    'total_records' => '0'
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            }

        } else {

            $sql = "SELECT COUNT(*) as total_records FROM tripitaka91_dict WHERE buddic_word LIKE :wordsearch";
            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':wordsearch', '%' . $wordsearch . '%', PDO::PARAM_STR);
            $stmt->execute();

            $result = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($result && $result['total_records'] > 0) {
                
                $check_sql = "SELECT * FROM log_history WHERE username = :username AND keyword = :wordsearch";
                $check_stmt = $conn->prepare($check_sql);
                $check_stmt->bindParam(':username', $username);
                $check_stmt->bindParam(':wordsearch', $wordsearch);
                $check_stmt->execute();

                if ($check_stmt->rowCount() > 0) {
                    $update_sql = "UPDATE log_history SET tmp_4 = :total_records WHERE username = :username AND keyword = :wordsearch";
                    $update_stmt = $conn->prepare($update_sql);
                    $update_stmt->bindParam(':username', $username);
                    $update_stmt->bindParam(':wordsearch', $wordsearch);
                    $update_stmt->bindParam(':total_records', $result['total_records']);

                    if ($update_stmt->execute()) {
                        echo json_encode([
                            'success' => true,
                            'message' => 'พบข้อมูลและทำการปรับปรุง',
                            'total_records' => $result['total_records']
                        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                    }
                } else {
                    
                    $insert_sql = "INSERT INTO log_history (username, keyword, count, tmp_4) 
                                    VALUES (:username, :wordsearch, 1, :total_records)";
                    $insert_stmt = $conn->prepare($insert_sql);
                    $insert_stmt->bindParam(':username', $username);
                    $insert_stmt->bindParam(':wordsearch', $wordsearch);
                    $insert_stmt->bindParam(':total_records', $result['total_records']);

                    if ($insert_stmt->execute()) {
                        echo json_encode([
                            'success' => true,
                            'message' => 'ไม่พบข้อมูล ดำเนินการเพิ่มข้อมูลใหม่',
                            'total_records' => $result['total_records']
                        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                    }
                }
            
            } else {
                
                $tmp_dummy = '-1';
                $check_sql = "SELECT * FROM log_history WHERE username = :username AND keyword = :wordsearch";
                $check_stmt = $conn->prepare($check_sql);
                $check_stmt->bindParam(':username', $username);
                $check_stmt->bindParam(':wordsearch', $wordsearch);
                $check_stmt->execute();

                if ($check_stmt->rowCount() > 0) {
                    $update_sql = "UPDATE log_history SET tmp_4 = :total_records WHERE username = :username AND keyword = :wordsearch";
                    $update_stmt = $conn->prepare($update_sql);
                    $update_stmt->bindParam(':username', $username);
                    $update_stmt->bindParam(':wordsearch', $wordsearch);
                    $update_stmt->bindParam(':total_records', $tmp_dummy);

                    if ($update_stmt->execute()) {
                        echo json_encode([
                            'success' => true,
                            'message' => 'พบข้อมูลและทำการปรับปรุง',
                            'total_records' => '0'
                        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                    }
                } else {
                    
                    $insert_sql = "INSERT INTO log_history (username, keyword, count, tmp_4) 
                                    VALUES (:username, :wordsearch, 1, :total_records)";
                    $insert_stmt = $conn->prepare($insert_sql);
                    $insert_stmt->bindParam(':username', $username);
                    $insert_stmt->bindParam(':wordsearch', $wordsearch);
                    $insert_stmt->bindParam(':total_records', $tmp_dummy);

                    if ($insert_stmt->execute()) {
                        echo json_encode([
                            'success' => true,
                            'message' => 'ไม่พบข้อมูล ดำเนินการเพิ่มข้อมูลใหม่',
                            'total_records' => '0'
                        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                    }
                }
            }
        }
    }else{
        echo json_encode([
            'success' => true,
            'message' => 'คุณยังไม่ป้อนคำค้นหา',
            'total_records' => '0'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
    
} catch (Exception $e) {
    echo json_encode([
        'error' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
