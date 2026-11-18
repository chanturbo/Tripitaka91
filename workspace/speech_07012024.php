<?php

require_once 'websiteconfig.php';
require_once 'create_folder.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

$webconfig = new WebsiteConfig();
$folderCreator = new FolderCreator();
$folderCreatorTitle = new FolderCreatorTitle();

$speech_api_key = $webconfig->getSpeechApiKey();;

$token = isset($_POST["token"]) ? $_POST["token"] : '';
$file_name = isset($_POST["file_name"]) ? $_POST["file_name"] : '';
$text_to_convert = isset($_POST["text_to_read"]) ? $_POST["text_to_read"] : '';
$title = isset($_POST["title"]) ? $_POST["title"] : '';

// ตรวจสอบความถูกต้องของ Token และค่า $file_name, $text_to_convert ก่อนดำเนินการต่อ
$tokenkey = $webconfig->getToken();
if (empty($token) || empty($file_name) || empty($text_to_convert) || $token != $tokenkey) {
    echo json_encode([
        'success' => false,
        'message' => 'ข้อมูลไม่ถูกต้อง'
    ], JSON_UNESCAPED_UNICODE);
    die(); // หยุดการทำงานถ้าข้อมูลไม่ถูกต้อง
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

    if (isset($responseDecoded['audioContent'])) {
        return $responseDecoded['audioContent'];
    }

    return false;
}

// รับข้อความที่จะอ่าน
$speech_data = getSound($text_to_convert);

// ตรวจสอบว่าสามารถอ่านเสียงได้หรือไม่
if ($speech_data) {
    //รับค่าโฟลเดอร์มา
    if ($title == '1') {
        $createFolderPathTitle = $folderCreatorTitle->createFolderTitle($file_name);
        $audio_filename = $createFolderPathTitle.'/'.$file_name.'.mp3';
    } else {
        $createdFolderPath = $folderCreator->createFolder($file_name);
        $audio_filename = $createdFolderPath.'/'.$file_name.'.mp3';
    }
        
    // ตรวจสอบว่าไฟล์เสียงมีอยู่หรือไม่
    if (!file_exists($audio_filename)) {
        // แปลงเสียงจาก base64 ไปยังไฟล์
        $audio_file_content = base64_decode($speech_data);

        // เขียนไฟล์ลงเครื่อง
        file_put_contents($audio_filename, $audio_file_content);
    }

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
?>