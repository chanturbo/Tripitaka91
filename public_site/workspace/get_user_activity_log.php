<?php
require_once 'db_connect.php';
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json; charset=UTF-8');

try {
    $db = new Database();
    $conn = $db->getConnection();

    // รับค่าจาก Flutter
    $page = isset($_POST['page']) ? intval($_POST['page']) : 0;
    $batchSize = isset($_POST['batchSize']) ? intval($_POST['batchSize']) : 50;

    // คำนวณ offset สำหรับการแบ่งหน้า
    $offset = $page * $batchSize;

    // ดึงข้อมูลจาก user_activity_log ด้วยการแบ่งหน้า
    $sql = "SELECT * FROM user_activity_log ORDER BY timestamp DESC LIMIT :batchSize OFFSET :offset";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':batchSize', $batchSize, PDO::PARAM_INT);
    $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();

    $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'logs' => $logs
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error fetching logs: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
