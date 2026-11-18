<?php

// กำหนด header ให้รับและส่งข้อมูลในรูปแบบ JSON
require_once 'db_connect.php';
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

/* ====== วางฟังก์ชันตรงนี้ ====== */

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

function filterBookDetailAndSum($detail, $start, $end) {
    if ($detail === '-' || empty($detail)) {
        return [
            'detail' => '-',
            'total' => 0
        ];
    }

    $items = explode('|', $detail);
    $filtered = [];
    $total = 0;

    foreach ($items as $item) {
        if (strpos($item, '#') === false) continue;

        list($book, $count) = explode('#', $item);
        $book = (int)$book;
        $count = (int)$count;

        if ($book >= $start && $book <= $end) {
            $filtered[] = $book . '#' . $count;
            $total += $count;
        }
    }

    return [
        'detail' => count($filtered) ? implode('|', $filtered) : '-',
        'total' => $total
    ];
}

function addMissingBooksWithZeroByGroup($detail, $start, $end) {    

    $map = [];

    // แปลงข้อมูลเดิมเป็น map
    if (!empty($detail) && $detail !== '-') {
        $items = explode('|', $detail);
        foreach ($items as $item) {
            if (strpos($item, '#') === false) continue;
            list($book, $count) = explode('#', $item);
            $map[(int)$book] = (int)$count;
        }
    }

    // เติมเล่มที่ขาดด้วย #0 (เฉพาะในช่วง)
    for ($i = $start; $i <= $end; $i++) {
        if (!array_key_exists($i, $map)) {
            $map[$i] = 0;
        }
    }

    // เรียงตามเล่ม
    ksort($map);

    // แปลงกลับเป็น string
    $result = [];
    foreach ($map as $book => $count) {
        $result[] = $book . '#' . $count;
    }

    return implode('|', $result);
}

function isCompleteBookSet($detail, $start, $end) {
    if (empty($detail) || $detail === '-') {
        return false;
    }

    $items = explode('|', $detail);
    $books = [];

    foreach ($items as $item) {
        if (strpos($item, '#') === false) continue;

        list($book, ) = explode('#', $item);
        $books[(int)$book] = true;
    }

    for ($i = $start; $i <= $end; $i++) {
        if (!isset($books[$i])) {
            return false; // ขาดเล่มใดเล่มหนึ่ง
        }
    }

    return true; // ครบทุกเล่มแล้ว
}

function mergeOnlyIncomingBooks($oldDetail, $newDetail, $start, $end) {
    $map = [];

    // 1️⃣ โหลดข้อมูลเดิม (เฉพาะในช่วง)
    if (!empty($oldDetail) && $oldDetail !== '-') {
        foreach (explode('|', $oldDetail) as $item) {
            if (strpos($item, '#') === false) continue;

            list($book, $count) = explode('#', $item);
            $book = (int)$book;

            if ($book >= $start && $book <= $end) {
                $map[$book] = (int)$count;
            }
        }
    }

    // 2️⃣ รวมข้อมูลใหม่ (เฉพาะในช่วง)
    if (!empty($newDetail) && $newDetail !== '-') {
        foreach (explode('|', $newDetail) as $item) {
            if (strpos($item, '#') === false) continue;

            list($book, $count) = explode('#', $item);
            $book = (int)$book;

            if ($book >= $start && $book <= $end) {
                // ✔ ถ้ามีอยู่ → overwrite
                // ✔ ถ้าไม่มี → เพิ่มใหม่ (แต่ยังอยู่ในช่วง)
                $map[$book] = (int)$count;
            }
        }
    }

    // 3️⃣ เรียงลำดับเล่ม
    ksort($map);

    // 4️⃣ สร้างผลลัพธ์
    $result = [];
    $total = 0;

    foreach ($map as $book => $count) {
        $result[] = $book . '#' . $count;
        $total += $count;
    }

    return [
        'detail' => count($result) ? implode('|', $result) : '-',
        'total'  => $total
    ];
}


function arabicToThaiNumbers($string) {
	$arabic = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
	$thai = ['๐', '๑', '๒', '๓', '๔', '๕', '๖', '๗', '๘', '๙'];
	return str_replace($arabic, $thai, $string);
}
/* ====== จบฟังก์ชัน ====== */

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
        
	$bookid = (int)$bookid; // แปลงเป็นตัวเลขก่อนเสมอ

	if ($bookid < 11) {
	    $book_tmp = 'tmp_1';
	    $book_detail = 'tmp_1detail';

	} elseif ($bookid < 75) { // 11 - 74
	    $book_tmp = 'tmp_2';
	    $book_detail = 'tmp_2detail';

	} else { // >= 75
	    $book_tmp = 'tmp_3';
	    $book_detail = 'tmp_3detail';
	}

        $db = new Database(); // สร้างอ็อบเจกต์ Database
        $conn = $db->getConnection(); // รับการเชื่อมต่อ PDO

        $sql_history = "SELECT $book_tmp, $book_detail as book_detail FROM log_history WHERE username = :username AND keyword = :wordsearch ORDER BY timestamp DESC LIMIT 1";
        $stmt_history = $conn->prepare($sql_history);
        $stmt_history->bindParam(':username', $username);        
        $stmt_history->bindParam(':wordsearch', $wordsearch);
        $stmt_history->execute();
        $result_history = $stmt_history->fetchAll(PDO::FETCH_ASSOC);        

        $book_detail_value = '-';
           
	if (!empty($result_history)) {
	    $row = $result_history[0];
	    $book_detail_value = $row['book_detail'] ?? '-';

		if ($bookid <= 10) {
			$start = 1;
			$end = 10;
		} elseif ($bookid <= 74) {
			$start = 11;
			$end = 74;
		} else {
			$start = 75;
			$end = 91;
		}

		if (isCompleteBookSet($book_detail_value, $start, $end)) {
			
			$filteredResult = filterBookDetailAndSum($book_detail_value, (int)$bookid, (int)$bookidend);
					
			echo json_encode([
				'success' => true,
				'message' => 'พบข้อมูลจาก cache UP',
				'total_records' => (string)$filteredResult['total'],
				'detail_records' => removeZeroCount($filteredResult['detail'])
			], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
			
		} else {
			
			if (!isCompleteBookSet($book_detail_value, (int)$bookid, (int)$bookidend)) {
				
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
				$formattedResult = addMissingBooksWithZeroByGroup($formattedResult, $bookid, $bookidend);
							
				$newValue = mergeOnlyIncomingBooks($book_detail_value,$formattedResult,$start, $end);
				
				//Update log_history
				$total  = isset($newValue['total']) 
					  ? (int)$newValue['total'] 
					  : 0;

				$detail = isset($newValue['detail']) 
					  ? $newValue['detail'] 
					  : '';					  
				$update_sql = "UPDATE log_history SET $book_tmp = :total_records, $book_detail = :book_detail WHERE username = :username AND keyword = :wordsearch";
				$update_stmt = $conn->prepare($update_sql);
				$update_stmt->bindParam(':username', $username);
				$update_stmt->bindParam(':wordsearch', $wordsearch);
				$update_stmt->bindValue(':total_records', $total, PDO::PARAM_INT);
				$update_stmt->bindValue(':book_detail', $detail, PDO::PARAM_STR);

				if ($update_stmt->execute()) {
					echo json_encode([
						'success' => true,
						'message' => 'พบข้อมูลและทำการปรับปรุง result UP',
						'total_records' => (string)$totalRecordsSum,
						'detail_records' => removeZeroCount($formattedResult)
					], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
				}
				
			} else {
				$filteredResult = filterBookDetailAndSum($book_detail_value, (int)$bookid, (int)$bookidend);
						
				echo json_encode([
					'success' => true,
					'message' => 'พบข้อมูลจาก cache',
					'total_records' => (string)$filteredResult['total'],
					'detail_records' => removeZeroCount($filteredResult['detail'])
				], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
			}
		}

        } else {

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
		    $formattedResult = addMissingBooksWithZeroByGroup($formattedResult, $bookid, $bookidend);
		    
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
		                    'message' => 'พบข้อมูลและทำการปรับปรุง result Down',
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
