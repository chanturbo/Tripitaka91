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

$speech_api_key = $webconfig->getSpeechApiAzureKey();
$region = 'southeastasia';

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
    die();
}

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

$audio_filename = $audio_folder_path . '/' . $file_name . '-m.mp3';

if($title == '4'){        
    $randomNumber = rand(10, 99); // สุ่มเลข 2 หลัก    
    $audio_filename = $audio_folder_path . '/' . $file_name . '-' . $randomNumber . '.mp3';
    $folderCreator->deleteMp3Files($audio_folder_path);
}

if (file_exists($audio_filename)) {
    echo json_encode([
        'success' => true,
        'message' => $audio_filename
    ], JSON_UNESCAPED_UNICODE);
    exit;
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

  $speech_data = getSoundFromAzure($text_to_convert, $speech_api_key, $region);

if ($speech_data) {
    // ดึงข้อมูล IP Address และ User-Agent
    $ip_address = getUserIP();
    $user_agent = 'Male -> ' . $_SERVER['HTTP_USER_AGENT'];

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
	    
    file_put_contents($audio_filename, $speech_data);
    echo json_encode([
        'success' => true,
        'message' => $audio_filename
    ], JSON_UNESCAPED_UNICODE);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'มีปัญหาในการดึงเสียง'
    ], JSON_UNESCAPED_UNICODE);
}


// ฟังก์ชันดึงเสียงจาก Azure
function getSoundFromAzure($text, $speech_api_key, $region)
{
    $accessTokenUri = "https://$region.api.cognitive.microsoft.com/sts/v1.0/issueToken";
    $ttsServiceUri = "https://$region.tts.speech.microsoft.com/cognitiveservices/v1";

    $options = array(
        'http' => array(
            'header'  => "Ocp-Apim-Subscription-Key: $speech_api_key\r\n" .
                         "Content-Length: 0\r\n",
            'method'  => 'POST',
        ),
    );
    $context = stream_context_create($options);
    $access_token = file_GET_contents($accessTokenUri, false, $context);

    if (!$access_token) {
        return false;
    }

    $ssml = "<speak version='1.0' xml:lang='th-TH'>
                <voice xml:lang='th-TH' xml:gender='Male' name='th-TH-NiwatNeural'>$text</voice>
             </speak>";

    $options = array(
        'http' => array(
            'header'  => "Content-type: application/ssml+xml\r\n" .
                         "X-Microsoft-OutputFormat: audio-16khz-32kbitrate-mono-mp3\r\n" .
                         "Authorization: Bearer $access_token\r\n" .
                         "User-Agent: PHP-Speech-Client\r\n", // เพิ่ม User-Agent
            'method'  => 'POST',
            'content' => $ssml,
        ),
    );
    $context = stream_context_create($options);
    $audio_data = file_GET_contents($ttsServiceUri, false, $context);

    return $audio_data ?: false;
}

?>
