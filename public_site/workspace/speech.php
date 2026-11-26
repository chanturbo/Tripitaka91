<?php

require_once 'websiteconfig.php';
require_once 'create_folder.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

$webconfig = new WebsiteConfig();
$folderCreator = new FolderCreator();
$folderCreatorSearch = new FolderCreatorSearch();
$folderCreatorTitle = new FolderCreatorTitle();
$folderCreatorDict = new FolderCreatorDict();
$folderCreatorTmp = new FolderCreatorTmp();

require_once 'user_info.php';
require_once 'db_connect.php';

$speech_api_key = $webconfig->getSpeechApiKey();

$token = $_POST["token"] ?? '';
$file_name = $_POST["file_name"] ?? '';
$text_to_convert = $_POST["text_to_read"] ?? '';
$title = $_POST["title"] ?? '';

// ตรวจสอบความถูกต้องของ Token และค่า $file_name, $text_to_convert ก่อนดำเนินการต่อ
$tokenkey = $webconfig->getToken();
if (empty($token) || empty($file_name) || empty($text_to_convert) || $token !== $tokenkey) {
    echo json_encode([
        'success' => false,
        'message' => 'ข้อมูลไม่ถูกต้อง'
    ], JSON_UNESCAPED_UNICODE);
    die(); // หยุดการทำงานถ้าข้อมูลไม่ถูกต้อง
}

// รับค่าโฟลเดอร์มา
// $audio_folder_path = ($title == '2') ? $folderCreatorSearch->createFolderSearch($file_name) : (($title == '1') ? $folderCreatorTitle->createFolderTitle($file_name) : $folderCreator->createFolder($file_name));
$audio_folder_path = ($title == '2') 
    ? $folderCreatorSearch->createFolderSearch($file_name) 
    : (($title == '1') 
        ? $folderCreatorTitle->createFolderTitle($file_name) 
        : (($title == '3') 
            ? $folderCreatorDict->createFolderDict($file_name) 
            : (($title == '4')
                ? $folderCreatorTmp->createFolderTmp($file_name)
                : $folderCreator->createFolder($file_name)
              )
          )
      );

$audio_filename = $audio_folder_path . '/' . $file_name . '.mp3';

if($title == '4'){        
    $randomNumber = rand(10, 99); // สุ่มเลข 2 หลัก    
    $audio_filename = $audio_folder_path . '/' . $file_name . '-' . $randomNumber . '.mp3';
    $folderCreator->deleteMp3Files($audio_folder_path);
}

function thaiToArabic($thaiNumber) {
    // อาร์เรย์เก็บคู่ของตัวเลขไทยและอารบิค
    $thaiDigits = ['๑', '๒', '๓', '๔', '๕', '๖', '๗', '๘', '๙', '๐'];
    $arabicDigits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  
    // แทนที่ตัวเลขไทยด้วยตัวเลขอารบิค
    $arabicNumber = str_replace($thaiDigits, $arabicDigits, $thaiNumber);
  
    return $arabicNumber;
  }

function thaiRelece($thaiText) {
    $output = ''; // สตริงผลลัพธ์ที่ต้องการ
    $length = mb_strlen($thaiText, 'UTF-8'); // ใช้ mb_strlen สำหรับข้อความ UTF-8
    
    for ($i = 0; $i < $length; $i++) {
        $char = mb_substr($thaiText, $i, 1, 'UTF-8'); // เอาตัวอักษรทีละตัว
        $prevChar = ($i > 0) ? mb_substr($thaiText, $i - 1, 1, 'UTF-8') : ''; // ตัวอักษรก่อนหน้า
        $nextChar = ($i < $length - 1) ? mb_substr($thaiText, $i + 1, 1, 'UTF-8') : ''; // ตัวอักษรถัดไป

        // ตรวจสอบว่าเป็นอักษรไทยที่มีเว้นวรรคทั้งก่อนหน้าและหลัง
        if (preg_match('/[ก-ฮ]/', $char) && $prevChar === ' ' && $nextChar === ' ') {
            // ถ้าเป็นอักษรไทย และมีเว้นวรรคด้านหน้าและหลัง เพิ่มสระ "ะ"
            $output .= $char . 'ะ';
        } else {
            // ถ้าไม่ใช่กรณีนี้ ให้แค่เพิ่มตัวอักษรนั้นลงในผลลัพธ์
            $output .= $char;
        }
    }
    
    return $output;
}

  $text_to_convert = thaiToArabic($text_to_convert);
  $text_to_convert = thaiRelece($text_to_convert);
  
if ($title == '4'){
    $speech_data = getSound($text_to_convert);

    // ตรวจสอบว่าสามารถอ่านเสียงได้หรือไม่
    if ($speech_data) {
        // แปลงเสียงจาก base64 ไปยังไฟล์
        $audio_file_content = base64_decode($speech_data);

        // เขียนไฟล์ลงเครื่อง
        file_put_contents($audio_filename, $audio_file_content);

        // สร้างลิงค์เสียง
        $audio_link =  $audio_filename;

        echo json_encode([
            'success' => true,
            'message' => $audio_link
        ], JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'มีปัญหาในการดึงเสียง'
        ], JSON_UNESCAPED_UNICODE);
    }
}else{
    // ตรวจสอบว่าไฟล์เสียงมีอยู่หรือไม่
    if (file_exists($audio_filename)) {
        $audio_link =  $audio_filename;

        echo json_encode([
            'success' => true,
            'message' => $audio_link
        ], JSON_UNESCAPED_UNICODE);
    } else {
        // รับข้อความที่จะอ่าน
        $speech_data = getSound($text_to_convert);

        // ตรวจสอบว่าสามารถอ่านเสียงได้หรือไม่
        if ($speech_data) {
        
	    // ดึงข้อมูล IP Address และ User-Agent
	    $ip_address = getUserIP();
	    $user_agent = 'Female -> ' . $_SERVER['HTTP_USER_AGENT'];

	    // ดึงข้อมูล Browser และ OS
	    $browser = getBrowser($user_agent) . '- [' . $audio_filename . ']';
	    $os = getOS($user_agent);

	    // เชื่อมต่อฐานข้อมูล
	    $db = new Database();
	    $conn = $db->getConnection();

	    // บันทึกข้อมูลลงตาราง
	    $sql = "INSERT INTO voice_generation_log (ip_address, browser, os, user_agent) 
		    VALUES (:ip_address, :browser, :os, :user_agent)";
	    $stmt = $conn->prepare($sql);
	    $stmt->bindParam(':ip_address', $ip_address);
	    $stmt->bindParam(':browser', $browser);
	    $stmt->bindParam(':os', $os);
	    $stmt->bindParam(':user_agent', $user_agent);
	    $stmt->execute();
	    
            // แปลงเสียงจาก base64 ไปยังไฟล์
            $audio_file_content = base64_decode($speech_data);

            // เขียนไฟล์ลงเครื่อง
            file_put_contents($audio_filename, $audio_file_content);

            // สร้างลิงค์เสียง
            $audio_link =  $audio_filename;

            echo json_encode([
                'success' => true,
                'message' => $audio_link
            ], JSON_UNESCAPED_UNICODE);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'มีปัญหาในการดึงเสียง'
            ], JSON_UNESCAPED_UNICODE);
        }
    }
}

// ฟังก์ชันสำหรับการดึงเสียง
function getSound($text)
{
    global $speech_api_key;

    $params = [
        "audioConfig" => [
            "audioEncoding" => "LINEAR16",
            "effectsProfileId" => [
                "small-bluetooth-speaker-class-device"
            ],
            "pitch" => 0,
            "speakingRate" => 1
        ],
        "input" => [
            "text" => $text
        ],
        "voice" => [
            "languageCode" => "th-TH",
            "name" => "th-TH-Standard-A"
        ]
    ];

    $data_string = json_encode($params);
    $url = 'https://texttospeech.googleapis.com/v1beta1/text:synthesize?key=' . $speech_api_key;

    $handle = curl_init($url);

    curl_setopt($handle, CURLOPT_CUSTOMREQUEST, "POST");
    curl_setopt($handle, CURLOPT_POSTFIELDS, $data_string);
    curl_setopt($handle, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($handle, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Content-Length: ' . strlen($data_string)
    ]);

    $response = curl_exec($handle);
    $responseDecoded = json_decode($response, true);
    curl_close($handle);

    return $responseDecoded['audioContent'] ?? false;
}
?>
