<?php
require_once 'websiteconfig.php';
require_once 'create_folder.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
$webconfig = new WebsiteConfig();
// API key มาจาก Google Cloud Console ผ่าน WebsiteConfig::getSpeechApiKey()
$speech_api_key = $webconfig->getSpeechApiKey();

// 2. ตรวจสอบว่า cURL ได้เปิดใช้งานหรือไม่
if (!function_exists('curl_init')) {
    die('cURL is not enabled. Enable it to use this script.');
}

// 5. เรียกใช้งาน saveSoundToFile ฟังก์ชัน
$token = $_GET["token"] ?? '';
$text_to_convert = $_GET["text_to_read"] ?? '';

$tokenkey = $webconfig->getToken();
if (empty($token) || empty($text_to_convert) || $token !== $tokenkey) {
    echo json_encode([
        'success' => false,
        'message' => 'ข้อมูลไม่ถูกต้อง'
    ], JSON_UNESCAPED_UNICODE);
    die(); // หยุดการทำงานถ้าข้อมูลไม่ถูกต้อง
}

$filename = "sounds/output.mp3"; // แทนที่ด้วยที่ที่คุณต้องการบันทึกไฟล์

if (saveSoundToFile($text_to_convert, $filename)) {
    // echo "ไฟล์เสียงถูกบันทึกเป็น: $filename";
    echo json_encode([
        'success' => true,
        'message' => $filename
    ], JSON_UNESCAPED_UNICODE);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'มีปัญหาในการบันทึกไฟล์เสียง'
    ], JSON_UNESCAPED_UNICODE);
}

// 3. สร้างฟังก์ชัน getSound
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

// 4. สร้างฟังก์ชัน saveSound
function saveSoundToFile($text, $filename)
{
    $speech_data = getSound($text);
    if ($speech_data) {
        $audio_file_content = base64_decode($speech_data);

        // บันทึกไฟล์เสียงลงที่เครื่องคอมพิวเตอร์
        if (file_put_contents($filename, $audio_file_content)) {
            return true;
        }
    }
    
    return false;
}
?>
