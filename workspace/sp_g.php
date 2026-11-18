<?php
require_once 'websiteconfig.php';
require_once 'create_folder.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
$webconfig = new WebsiteConfig();
// 1. กำหนดค่า API key ที่ได้จาก Google Cloud Console:
/*
$speech_api_key = $webconfig->getSpeechApiAzureKey();
$region = 'southeastasia';
// 2. ตรวจสอบว่า cURL ได้เปิดใช้งานหรือไม่
if (!function_exists('curl_init')) {
    die('cURL is not enabled. Enable it to use this script.');
}

// 5. เรียกใช้งาน saveSoundToFile ฟังก์ชัน

$text_to_convert = 'คำนำ
พระพุทธะวะจะนะ คือ พระไตรปิฎก รวมเป็นศาสนาธรรมคำสอนของ
พระพุทธเจ้า จัดเป็นองค์ 9 คือ
สุตตะ ได้แก่อุภโตวิภังค์ นินเทส ขันธกะ ปริวาร พระสูตรต่างๆ
มีมงคลสูตรเป็นต้น
เคยยะ คือพระสูตรที่ประกอบด้วยคาถาทั้งหมด
เวยยากรณะ คือ พระอภิธรรมปิ ฎกทั้งหมด พระสูตรที่ไม่มี 
และพระพุทธะวะจะนะที่ไม่ได้จัดเข้าในองค์ 8 ได้ชื่อว่าเวยยากรณะทั้งหมด
คาถา คือพระธรรมบท เถรคาถา เถรีคาถา และคาถาล้วนๆ ที่ไม่มี
ชื่อว่าสูตรในสูตตนิบาต
อุทาน คือพระสูตร 82 สูตร ที่พระพุทธเจ้าทรงเปล่งด้วยโสมนัสญาณ
อิติวุตตกะ คือพระสูตร 110 สูตร ที่ขึ้นต้นด้วยคำว่า ข้อนี้สมจริง
ดังคำที่พระผู้มีพระภาคเจ้าตรัสไว้
ชา ดก เป็นการแสดงเรื่องในอดีตชาติของพระพุทธเจ้า มี อะปัณณะกะ
ชา ดกเป็นต้น มีทั้งหมด 550
อัพภูตธรรม คือพระสูตรที่ปฏิสังยุตด้วยอัจฉริยอัพภูตธรรมทั้งหมด
เวทัล ละ คือระเบียบคำที่ผู้ถามได้ความรู้แจ้งและความยินดี  ถาม
ต่อๆ ขึ้นไป ดังจูฬะเวทัลละสูตร มหาเวทัลละสูตร สัมมาทิฏฐิสูตร และ
สักกะปัญหะสูตร เป็นต้น
พระพุทธะวะจะนะเหล่านี้ โดยสภาพแห่งธรรมแล้ว เป็นสัจจธรรมที่ทรง
แสดงว่า เป็นธรรมที่ลึกซึ้งรู้ได้ยาก รู้ตามเห็นตามได้ยาก สงบ';


if (empty($text_to_convert)) {
    echo json_encode([
        'success' => false,
        'message' => 'ข้อมูลไม่ถูกต้อง'
    ], JSON_UNESCAPED_UNICODE);
    die(); // หยุดการทำงานถ้าข้อมูลไม่ถูกต้อง
}

$filename = "sounds/output.mp3"; // แทนที่ด้วยที่ที่คุณต้องการบันทึกไฟล์

if (saveSoundToFile($text_to_convert, $filename,$speech_api_key, $region)) {
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


// 4. สร้างฟังก์ชัน saveSound
function saveSoundToFile($text, $filename,$speech_api_key, $region)
{

$speech_data = getSoundFromAzure($text, $speech_api_key, $region);

if ($speech_data) {
    file_put_contents($filename, $speech_data);
    echo json_encode([
        'success' => true,
        'message' => $filename
    ], JSON_UNESCAPED_UNICODE);
    return true;
} else {
    echo json_encode([
        'success' => false,
        'message' => 'มีปัญหาในการดึงเสียง'
    ], JSON_UNESCAPED_UNICODE);
    return false;
}
return true;
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
*/
?>
