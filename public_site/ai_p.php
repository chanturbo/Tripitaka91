<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
	<link rel="shortcut icon" href="favicon.ico">
</head>
<body>
<?php

function countTokens($text) {
    // ภาษาไทย: 1 Token ≈ 2 ตัวอักษร
    return ceil(mb_strlen($text, 'UTF-8') / 2);
}

function trimToMaxTokens($text, $maxTokens = 8192) {
    while (countTokens($text) > $maxTokens) {
        // ตัดข้อความลงทีละ 50 ตัวอักษร เพื่อลด Token
        $text = mb_substr($text, 0, mb_strlen($text, 'UTF-8') - 50, 'UTF-8');
    }
    return $text;
}

// เรียกใช้งานคลาส Database
require_once 'workspace/db_connect.php';
require_once 'workspace/websiteconfig.php';

// ตั้งค่า OpenAI API Key
$apiKey = (new WebsiteConfig())->getOpenAiApiKey();

// เชื่อมต่อฐานข้อมูล
$db = new Database();
$pdo = $db->getConnection();

// รับค่า book_id จาก GET request
$book_id = isset($_GET['book_id']) ? (float) $_GET['book_id'] : 1;

if ($book_id <= 0) {
    die("❌ โปรดระบุค่า book_id ที่ถูกต้อง");
}

// ดึงข้อมูลจาก tripitaka91_91title และ tripitaka91_combined_details โดยกรองตาม book_id
$query = "
    SELECT t91.tripitaka91_no, t91.tripitaka91_code, 
           t91.tripitaka91_title, 
           t91.tripitaka91_book, t91.tripitaka91_page, t91.tripitaka91_line
    
    FROM tripitaka91_91title AS t91
    
    WHERE t91.tripitaka91_code = :book_id
    ORDER BY t91.tripitaka91_page
";
$stmt = $pdo->prepare($query);
$stmt->execute([':book_id' => $book_id]);
$contents = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($contents as $content) {
    // ตรวจสอบว่าข้อมูลมีอยู่แล้วหรือไม่
    $checkQuery = "
        SELECT COUNT(*) FROM tripitaka91_embedding
        WHERE tripitaka91_no = :tripitaka91_no
        AND tripitaka91_code = :tripitaka91_code
        AND tripitaka91_book = :tripitaka91_book
        AND tripitaka91_page = :tripitaka91_page
        AND tripitaka91_line = :tripitaka91_line
    ";
    $checkStmt = $pdo->prepare($checkQuery);
    $checkStmt->execute([
        ':tripitaka91_no' => $content['tripitaka91_no'],
        ':tripitaka91_code' => $content['tripitaka91_code'],
        ':tripitaka91_book' => $content['tripitaka91_book'],
        ':tripitaka91_page' => $content['tripitaka91_page'],
        ':tripitaka91_line' => $content['tripitaka91_line'],
    ]);
    $exists = $checkStmt->fetchColumn();

    if ($exists > 0) {
//        echo "⚠️ ข้อมูลสำหรับ tripitaka91_book: {$content['tripitaka91_book']} และ tripitaka91_page: {$content['tripitaka91_page']} มีอยู่แล้วในฐานข้อมูล ข้าม...\n<br>";
        continue; // ข้ามการเพิ่มข้อมูลใหม่ถ้าข้อมูลมีอยู่แล้ว
    }

//	echo "<br>" . $content['tripitaka91_page'] . "<br>";
	
	
    // รวมข้อความจาก title, book_detail และ URL
    $text = trim($content['tripitaka91_title']);
    $str_r = $content['tripitaka91_book'] .'/' . $content['tripitaka91_page'] . '/'. $content['tripitaka91_line'];
    $text = str_replace($str_r,'',$text);
    
    if (!empty($text)) {

	// 🔹 ตัวอย่างข้อความภาษาไทย
	$originalText = $text; // ใส่ข้อความจริงที่ต้องส่ง
	$maxTokens = 3900;
	$tokenCount = countTokens($originalText);
	$tokenCountOld = $tokenCount;	
	
	if ($tokenCount > $maxTokens) {
		
		//echo "🔹 จำนวน Token ก่อนตัด: $tokenCount book_id:" . $content['tripitaka91_book'] ." page : " . $content['tripitaka91_page'] ."\n<br>";	
		$trimmedText = trimToMaxTokens($originalText, $maxTokens);
//		echo "✅ ข้อความถูกตัดให้เหลือ Token ไม่เกิน $maxTokens\n<br>";
		$tokenCount = countTokens($trimmedText);
//		echo '<br>'. $tokenCount ."<br><br>";
		$text = $trimmedText;
	} 	    	
	
	echo "<br>" . $content['tripitaka91_page'] . '-Old:' . $tokenCountOld . ' -New:'. $tokenCount ."<br>";
	
//	if ($content['tripitaka91_page'] == '221'){
        // เรียก API OpenAI เพื่อสร้าง Embedding
        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_URL => "https://api.openai.com/v1/embeddings",
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_HTTPHEADER => [
                "Content-Type: application/json",
                "Authorization: Bearer $apiKey"
            ],
            CURLOPT_POSTFIELDS => json_encode([
                "model" => "text-embedding-ada-002",
                "input" => $text
            ])
        ]);

        $response = curl_exec($curl);
        curl_close($curl);

        $data = json_decode($response, true);

        if (isset($data['data'][0]['embedding'])) {
            $embedding = json_encode($data['data'][0]['embedding']); // แปลงเป็น JSON

            // บันทึก Embedding ลงฐานข้อมูล tripitaka91_embedding
            $insertQuery = "
                INSERT INTO tripitaka91_embedding (tripitaka91_no, tripitaka91_code, tripitaka91_book, tripitaka91_page, tripitaka91_line, embedding)
                VALUES (:tripitaka91_no, :tripitaka91_code, :tripitaka91_book, :tripitaka91_page, :tripitaka91_line, :embedding)
            ";
            $stmt = $pdo->prepare($insertQuery);
            $stmt->execute([
                ':tripitaka91_no' => $content['tripitaka91_no'],
                ':tripitaka91_code' => $content['tripitaka91_code'],
                ':tripitaka91_book' => $content['tripitaka91_book'],
                ':tripitaka91_page' => $content['tripitaka91_page'],
                ':tripitaka91_line' => $content['tripitaka91_line'],
                ':embedding' => $embedding
            ]);
            echo "✅ เพิ่มข้อมูล Embedding สำเร็จสำหรับ tripitaka91_book: {$content['tripitaka91_book']} tripitaka91_page: {$content['tripitaka91_page']}\n<br>";
        } else {
            echo "❌ OpenAI API Error: " . json_encode($data) . "\n<br>";
        }
//      }
    }
}

echo "✅ กระบวนการบันทึก Embeddings เสร็จสิ้นสำหรับ book_id = $book_id!";

?>
</body>
