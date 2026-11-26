<?php

// กำหนด header ให้รับและส่งข้อมูลในรูปแบบ JSON
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

function removeZeroCount($detail) {
    if (empty($detail) || $detail === '-') {
        return '-';
    }

    $items = explode('|', $detail);
    $filtered = [];

    foreach ($items as $item) {
        if (strpos($item, '#') === false) continue;

        list($book, $count) = explode('#', $item);

        if ((int)$count > 0) {
            $filtered[] = $book . '#' . (int)$count;
        }
    }

    return count($filtered) ? implode('|', $filtered) : '-';
}


try {
    $webconfig = new WebsiteConfig();
    $bookid = isset($_POST["bookid"]) ? $_POST["bookid"] : '';
    $bookidend = isset($_POST["bookidend"]) ? $_POST["bookidend"] : '';
    $wordsearch = isset($_POST["wordsearch"]) ? $_POST["wordsearch"] : '';
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : 'guest';

    //ตรวจสอบความถูกต้องของ Token ก่อนดำเนินการต่อ
    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    if (($bookid != '' ) && ($bookidend != '' ) && ($wordsearch !='')){
        
        $book_tmp = 'tmp_1';
        $book_detail = 'tmp_1detail';
        if ($bookid == '1'){
            $book_tmp = 'tmp_1';
            $book_detail = 'tmp_1detail';
        }else if ($bookid == '11'){
            $book_tmp = 'tmp_2';
            $book_detail = 'tmp_2detail';
        }else{
            $book_tmp = 'tmp_3';
            $book_detail = 'tmp_3detail';
        }

        $db = new Database(); // สร้างอ็อบเจกต์ Database
        $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO

        // $sql_history = "SELECT $book_tmp FROM log_history WHERE username = :username AND keyword = :wordsearch ORDER BY timestamp DESC LIMIT 10";
        // $stmt_history = $conn->prepare($sql_history);
        // $stmt_history->bindParam(':username', $username);        
        // $stmt_history->bindParam(':wordsearch', $wordsearch);
        // $stmt_history->execute();
        // $result_history = $stmt_history->fetchColumn();
        // $result_history = $stmt_history->fetch(PDO::FETCH_ASSOC);
        // print($result_history);
        // if ($result_history && $result_history[0] != '0') {

        $sql_history = "SELECT $book_tmp, $book_detail as book_detail FROM log_history WHERE username = :username AND keyword = :wordsearch ORDER BY timestamp DESC LIMIT 20";
        $stmt_history = $conn->prepare($sql_history);
        $stmt_history->bindParam(':username', $username);        
        $stmt_history->bindParam(':wordsearch', $wordsearch);
        $stmt_history->execute();
        $result_history = $stmt_history->fetchAll(PDO::FETCH_ASSOC);
        
        // เพิ่มตัวแปร $book_tmp_value และ $book_detail_value โดยกำหนดค่าเริ่มต้น
        $book_tmp_value = '0';
        $book_detail_value = '-';
        
        // ใช้ foreach เพื่อไล่ทุก row ใน $result_history
        foreach ($result_history as $row) {
            $book_tmp_value = $row[$book_tmp];
            $book_detail_value = $row['book_detail'];
        }            
        
        if ($result_history && $book_tmp_value != '0') {
            // if ($result_history[0] != '-1'){
            if ($result_history != '-1') {    
                // $update_sql = "UPDATE log_history SET count = count + 1 WHERE username = :username AND keyword = :wordsearch";
                // $update_stmt = $conn->prepare($update_sql);
                // $update_stmt->bindParam(':username', $username);
                // $update_stmt->bindParam(':wordsearch', $wordsearch);        
        
                // if ($update_stmt->execute()) {
                //     echo json_encode([
                //         'success' => true,
                //         'message' => 'พบข้อมูลและทำการปรับปรุง',
                //         'total_records' => $book_tmp_value,
                //         'detail_records' => $book_detail_value
                //     ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                // }
                
                $book_detail_value = removeZeroCount($book_detail_value);

                echo json_encode([
                    'success' => true,
                    'message' => 'พบข้อมูลและทำการปรับปรุง',
                    'total_records' => $book_tmp_value,
                    'detail_records' => $book_detail_value
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            } else {
                echo json_encode([
                    'success' => true,
                    'message' => 'ไม่พบข้อมูลมีการบันทึกข้อมูลแล้ว',
                    'total_records' => '0',
                    'detail_records' => '-'  // เปลี่ยนค่าเป็น ''
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            }
        } else {

		function arabicToThaiNumbers($string) {
		    $arabic = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
		    $thai = ['๐', '๑', '๒', '๓', '๔', '๕', '๖', '๗', '๘', '๙'];
		    return str_replace($arabic, $thai, $string);
		}

		$wordsearch_thai = arabicToThaiNumbers($wordsearch);

		$sql = "SELECT book_id, COUNT(*) as total_records FROM tripitaka91_91book_line 
			WHERE book_id BETWEEN :bookid AND :bookidend 
			AND (book_detail LIKE :wordsearch_arabic OR book_detail LIKE :wordsearch_thai)
			GROUP BY book_id";

		$stmt = $conn->prepare($sql);
		$stmt->bindParam(':bookid', $bookid, PDO::PARAM_INT);
		$stmt->bindParam(':bookidend', $bookidend, PDO::PARAM_INT);
		$stmt->bindValue(':wordsearch_arabic', '%' . $wordsearch . '%', PDO::PARAM_STR);
		$stmt->bindValue(':wordsearch_thai', '%' . $wordsearch_thai . '%', PDO::PARAM_STR);
		$stmt->execute();
            
/*
            $sql = "SELECT book_id, COUNT(*) as total_records FROM tripitaka91_91book_line 
                    WHERE book_id BETWEEN :bookid AND :bookidend AND book_detail LIKE :wordsearch 
                    GROUP BY book_id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':bookid', $bookid, PDO::PARAM_INT);
            $stmt->bindParam(':bookidend', $bookidend, PDO::PARAM_INT);            
            $stmt->bindValue(':wordsearch', '%' . $wordsearch . '%', PDO::PARAM_STR);            
            $stmt->execute();
*/
            // $result = $stmt->fetch(PDO::FETCH_ASSOC);
            // Fetch all results
            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Initialize a variable to store the total_records        
            $totalRecordsSum = 0;
            // Initialize an empty string to store the formatted result
            $formattedResult = '';

            // Loop through the results and accumulate the total_records
            foreach ($results as $row) {
                $totalRecordsSum += $row['total_records'];
                $formattedResult .= $row['book_id'] . '#' . $row['total_records'] . '|';
            }
            
            $formattedResult = rtrim($formattedResult, '|');

            if ($results && $totalRecordsSum > 0) {

                $check_sql = "SELECT * FROM log_history WHERE username = :username AND keyword = :wordsearch";
                $check_stmt = $conn->prepare($check_sql);
                $check_stmt->bindParam(':username', $username);
                $check_stmt->bindParam(':wordsearch', $wordsearch);
                $check_stmt->execute();

                if ($check_stmt->rowCount() > 0) {
                    $update_sql = "UPDATE log_history SET $book_tmp = :total_records, $book_detail = :book_detail WHERE username = :username AND keyword = :wordsearch";
                    $update_stmt = $conn->prepare($update_sql);
                    $update_stmt->bindParam(':username', $username);
                    $update_stmt->bindParam(':wordsearch', $wordsearch);
                    $update_stmt->bindParam(':total_records', $totalRecordsSum);
                    $update_stmt->bindParam(':book_detail', $formattedResult);

                    if ($update_stmt->execute()) {
                        echo json_encode([
                            'success' => true,
                            'message' => 'พบข้อมูลและทำการปรับปรุง result',
                            'total_records' => $totalRecordsSum,
                            'detail_records' => removeZeroCount($formattedResult)
                        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                    }
                } else {
                    
                    $insert_sql = "INSERT INTO log_history (username, keyword, count, $book_tmp, $book_detail) 
                                    VALUES (:username, :wordsearch, 1, :total_records, :book_detail)";
                    $insert_stmt = $conn->prepare($insert_sql);
                    $insert_stmt->bindParam(':username', $username);
                    $insert_stmt->bindParam(':wordsearch', $wordsearch);
                    $insert_stmt->bindParam(':total_records', $totalRecordsSum);
                    $insert_stmt->bindParam(':book_detail', $formattedResult);

                    if ($insert_stmt->execute()) {
                        echo json_encode([
                            'success' => true,
                            'message' => 'ไม่พบข้อมูล ดำเนินการเพิ่มข้อมูลใหม่',
                            'total_records' => $totalRecordsSum,
                            'detail_records' => removeZeroCount($formattedResult)
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
                    $update_sql = "UPDATE log_history SET $book_tmp = :total_records WHERE username = :username AND keyword = :wordsearch";
                    $update_stmt = $conn->prepare($update_sql);
                    $update_stmt->bindParam(':username', $username);
                    $update_stmt->bindParam(':wordsearch', $wordsearch);
                    $update_stmt->bindParam(':total_records', $tmp_dummy);

                    if ($update_stmt->execute()) {
                        echo json_encode([
                            'success' => true,
                            'message' => 'พบข้อมูลและทำการปรับปรุง tmp_dummy',
                            'total_records' => '0',
                            'detail_records' => '-'
                        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                    }
                } else {
                    
                    $insert_sql = "INSERT INTO log_history (username, keyword, count, $book_tmp) 
                                    VALUES (:username, :wordsearch, 1, :total_records)";
                    $insert_stmt = $conn->prepare($insert_sql);
                    $insert_stmt->bindParam(':username', $username);
                    $insert_stmt->bindParam(':wordsearch', $wordsearch);
                    $insert_stmt->bindParam(':total_records', $tmp_dummy);

                    if ($insert_stmt->execute()) {
                        echo json_encode([
                            'success' => true,
                            'message' => 'ไม่พบข้อมูล ดำเนินการเพิ่มข้อมูลใหม่ tmp_dummy',
                            'total_records' => '0',
                            'detail_records' => '-'
                        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                    }
                }
            }
        }
    }else{
        echo json_encode([
            'success' => true,
            'message' => 'คุณยังไม่ป้อนคำค้นหา',
            'total_records' => '0',
            'detail_records' => '-'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }

} catch (Exception $e) {
    echo json_encode([
        'error' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
