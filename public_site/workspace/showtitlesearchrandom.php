<?php
require_once 'websiteconfig.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json; charset=utf-8');

$webconfig = new WebsiteConfig();
$token = isset($_POST["token"]) ? $_POST["token"] : '';
$query = isset($_POST["wordsearch"]) ? $_POST["wordsearch"] : '';
$top_k = isset($_POST["top_k"]) ? $_POST["top_k"] : '100';
    
//$query = "เที่ยวไปผู้เดียว";


// ตรวจสอบความถูกต้องของ Token ก่อนดำเนินการต่อ

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    if ($query != '') {

	$url = "https://search.tripitaka91.com/search";

	$data = array("query" => $query,"top_k" => $top_k);
	$data_string = json_encode($data);

	$ch = curl_init($url);
	curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
	curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_HTTPHEADER, array(
	    'Content-Type: application/json',
	    'Content-Length: ' . strlen($data_string)
	));

	$response = curl_exec($ch);

	if (curl_errno($ch)) {
	    echo json_encode([
		'success' => false,
		'message' => 'cURL Error: ' . curl_error($ch)
	    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
	} else {
	    $result = json_decode($response, true);

	    if (!empty($result['results'])) {
		echo json_encode([
		    'success' => true,
		    'message' => $result['results']
		], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
	    } else {
		echo json_encode([
		    'success' => false,
		    'message' => 'ไม่พบข้อมูลที่ใกล้เคียงกับคำค้นหา'
		], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
	    }
	}
	}


?>

