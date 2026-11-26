<?
// ตั้งค่า TimeZone เป็น UTC
date_default_timezone_set('UTC');

// ดึงเวลาปัจจุบันใน TimeZone ที่ถูกตั้งค่า
$currentTimeInUTC = gmdate('Y-m-d H:i:s');

$currentTimeInBangkok = date('Y-m-d H:i:s', strtotime($currentTimeInUTC));
echo "Current Time in Bangkok: $currentTimeInBangkok<br>";

// ตั้งค่า TimeZone เป็น Asia/Bangkok
date_default_timezone_set('Asia/Bangkok');

// แปลงเวลาใน TimeZone ที่ถูกตั้งค่าใหม่
$currentTimeInBangkok = date('Y-m-d H:i:s', strtotime($currentTimeInUTC . ' +7 hours'));

echo "Current Time in Bangkok: $currentTimeInBangkok";

?>
