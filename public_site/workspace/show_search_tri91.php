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
    $bookid = isset($_POST["bookid"]) ? $_POST["bookid"] : '';
    $wordsearch = isset($_POST["wordsearch"]) ? $_POST["wordsearch"] : '';
    $token = isset($_POST["token"]) ? $_POST["token"] : '';
    $username = isset($_POST["username"]) ? $_POST["username"] : 'guest';
    $page = isset($_POST["page"]) ? $_POST["page"] : 1;  // เพิ่มตัวแปร page สำหรับ pagination
    $recordsPerPage = 50;  // จำนวนรายการที่ต้องการให้แสดงต่อหน้า

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die();
    }

    if (($bookid != '' ) && ($wordsearch !='')){                
        $db = new Database();
        $conn = $db->getConnection();

        $startFrom = ($page - 1) * $recordsPerPage;
        /*
        $sql_tripitaka = "SELECT * FROM tripitaka91_91book_line WHERE book_id = :bookid AND book_detail LIKE :wordsearch LIMIT $startFrom, $recordsPerPage";

        $stmt_tripitaka = $conn->prepare($sql_tripitaka);
        $stmt_tripitaka->bindParam(':bookid', $bookid);
        $stmt_tripitaka->bindValue(':wordsearch', '%' . $wordsearch . '%', PDO::PARAM_STR);
        $stmt_tripitaka->execute();
        $result_tripitaka = $stmt_tripitaka->fetchAll(PDO::FETCH_ASSOC);
	*/
	function arabicToThaiNumbers($string) {
	    $arabic = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
	    $thai = ['๐', '๑', '๒', '๓', '๔', '๕', '๖', '๗', '๘', '๙'];
	    return str_replace($arabic, $thai, $string);
	}

	$wordsearch_thai = arabicToThaiNumbers($wordsearch);

	$sql_tripitaka = "SELECT * FROM tripitaka91_91book_line 
		          WHERE book_id = :bookid 
		          AND (book_detail LIKE :wordsearch_arabic OR book_detail LIKE :wordsearch_thai)
		          LIMIT :startFrom, :recordsPerPage";

	$stmt_tripitaka = $conn->prepare($sql_tripitaka);
	$stmt_tripitaka->bindParam(':bookid', $bookid, PDO::PARAM_INT);
	$stmt_tripitaka->bindValue(':wordsearch_arabic', '%' . $wordsearch . '%', PDO::PARAM_STR);
	$stmt_tripitaka->bindValue(':wordsearch_thai', '%' . $wordsearch_thai . '%', PDO::PARAM_STR);
	$stmt_tripitaka->bindValue(':startFrom', (int)$startFrom, PDO::PARAM_INT);
	$stmt_tripitaka->bindValue(':recordsPerPage', (int)$recordsPerPage, PDO::PARAM_INT);
	$stmt_tripitaka->execute();

	$result_tripitaka = $stmt_tripitaka->fetchAll(PDO::FETCH_ASSOC);

        $response = array();
        
        foreach ($result_tripitaka as $row_tripitaka) {
            $lineBefore = $row_tripitaka['book_lines'] - 1;
            $sqlBefore = "SELECT * FROM tripitaka91_91book_line WHERE book_id = :bookid AND book_pages = :book_pages AND book_line = :lineBefore";
            $stmtBefore = $conn->prepare($sqlBefore);
            $stmtBefore->bindParam(':bookid', $bookid);
            $stmtBefore->bindParam(':book_pages', $row_tripitaka['book_pages']);
            $stmtBefore->bindParam(':lineBefore', $lineBefore);
            $stmtBefore->execute();
            $rowBefore = $stmtBefore->fetch(PDO::FETCH_ASSOC);

            $lineAfter = $row_tripitaka['book_lines'] + 1;
            $sqlAfter = "SELECT * FROM tripitaka91_91book_line WHERE book_id = :bookid AND book_pages = :book_pages AND book_line = :lineAfter";
            $stmtAfter = $conn->prepare($sqlAfter);
            $stmtAfter->bindParam(':bookid', $bookid);
            $stmtAfter->bindParam(':book_pages', $row_tripitaka['book_pages']);
            $stmtAfter->bindParam(':lineAfter', $lineAfter);
            $stmtAfter->execute();
            $rowAfter = $stmtAfter->fetch(PDO::FETCH_ASSOC);

            $strBefore = ($rowBefore) ? $rowBefore['book_detail'] : '';
            $strAfter = ($rowAfter) ? $rowAfter['book_detail'] : '';
            
            $cleanedString = sanitizeString($strBefore . $row_tripitaka['book_detail'] . $strAfter 
                                                       . "|" . $row_tripitaka['book_id'] . "|" . $row_tripitaka['book_pages'] 
                                                       . "|" . $row_tripitaka['book_lines']);

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
                'message' => 'ไม่พบข้อมูล/โหลดข้อมูลหมดแล้ว',
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        }
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'คุณยังไม่ป้อนคำค้นหา',           
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
