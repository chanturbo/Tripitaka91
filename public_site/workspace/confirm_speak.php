<?php

require_once 'db_connect.php';
require_once 'websiteconfig.php';
require_once 'create_folder.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

try {
    $webconfig = new WebsiteConfig();
    $token = isset($_POST["token"]) ? $_POST["token"] : '';    
    $wordsearch = isset($_POST["wordsearch"]) ? $_POST["wordsearch"] : '';
    $book_speak = isset($_POST["book_speak"]) ? $_POST["book_speak"] : '';
    // print($book_speak);
    // print($wordsearch);

    $tokenkey = $webconfig->getToken();
    if ($token != $tokenkey) {
        echo json_encode([
            'success' => false,
            'message' => 'Token ไม่ถูกต้อง'
        ], JSON_UNESCAPED_UNICODE);
        die(); // หยุดการทำงานถ้า Token ไม่ถูกต้อง
    }

    if ($wordsearch != '') {
        $db = new Database();
        $conn = $db->getConnection();
        $conn->beginTransaction(); // เริ่ม Transaction

        $sql_update_log = "UPDATE log_speak SET speak_suscess = 1 WHERE words = :wordsearch";
        $stmt_update_log = $conn->prepare($sql_update_log);
        $stmt_update_log->bindParam(':wordsearch', $wordsearch, PDO::PARAM_STR);
        $stmt_update_log->execute();

        $sql_dict = "SELECT * FROM tripitaka91_dict WHERE buddic_detail LIKE :wordsearch OR buddic_word LIKE :wordsearch";
        $stmt_dict = $conn->prepare($sql_dict);
        $searchTerm = '%' . $wordsearch . '%';
        $stmt_dict->bindParam(':wordsearch', $searchTerm, PDO::PARAM_STR);
        $stmt_dict->execute();
        $response_dict = $stmt_dict->fetchAll(PDO::FETCH_ASSOC);    

        if (!empty($response_dict)) {
            foreach ($response_dict as $row_dict) {
                $textTitleReplace = preg_replace('/\s+/', '', $row_dict['buddic_word']);
                $filePath = 'sounds/dict/dict_' . $textTitleReplace . '.mp3';

                if (file_exists($filePath) && is_file($filePath)) {
                    unlink($filePath); // ลบไฟล์ MP3
                    //echo 'Deleted file: ' . $filePath;
                } else {
                    //echo 'File not found: ' . $filePath;
                }
            }
        }

        $sql_dictbt = "SELECT * FROM tripitaka91_dictbt WHERE buddic_bt_detail LIKE :wordsearch OR buddic_bt_word LIKE :wordsearch";
        $stmt_dictbt = $conn->prepare($sql_dictbt);
        $searchTerm = '%' . $wordsearch . '%';
        $stmt_dictbt->bindParam(':wordsearch', $searchTerm, PDO::PARAM_STR);
        $stmt_dictbt->execute();
        $response_dictbt = $stmt_dictbt->fetchAll(PDO::FETCH_ASSOC);    

        if (!empty($response_dictbt)) {
            foreach ($response_dictbt as $row_dictbt) {
                $textTitleReplace = preg_replace('/\s+/', '', $row_dictbt['buddic_bt_word']);
                $filePath = 'sounds/dict/dict_' . $textTitleReplace . '.mp3';

                if (file_exists($filePath) && is_file($filePath)) {
                    unlink($filePath); // ลบไฟล์ MP3
                    //echo 'Deleted file: ' . $filePath;
                } else {
                    //echo 'File not found: ' . $filePath;
                }
            }
        }

        // ค้นหาข้อมูลจากตาราง tripitaka91_91title
        $sql_title = "SELECT * FROM tripitaka91_91title WHERE tripitaka91_title LIKE :wordsearch";
        $stmt_title = $conn->prepare($sql_title);
        $stmt_title->bindValue(':wordsearch', '%' . $wordsearch . '%', PDO::PARAM_STR);
        $stmt_title->execute();
        $response_title = $stmt_title->fetchAll(PDO::FETCH_ASSOC);    

        if (!empty($response_title)) {
            // ตรวจสอบและบันทึกข้อมูลลงในตาราง log_speak_result
            foreach ($response_title as $row_title) {
                // ตรวจสอบว่าข้อมูลในตาราง tripitaka91_91title มี book_speak ตรงกับคำค้นหาหรือไม่
                if ($row_title['book_speak'] === null) {
                    $new_book_speak = $book_speak;
                } else {
                    // ตรวจสอบว่าข้อมูลในตาราง tripitaka91_91title มี book_speak ตรงกับคำค้นหาหรือไม่
                    if (strpos($row_title['book_speak'], $book_speak) === false) {
                        // ไม่มีข้อความเดียวกัน ทำการอัปเดต
                        $new_book_speak = $row_title['book_speak'] . ', ' . $book_speak;
                    } else {
                        // มีข้อความเดียวกัน ไม่ต้องทำการอัปเดต
                        continue;
                    }
                }
                
                // อัปเดตฐานข้อมูล
                $sql_update = "UPDATE tripitaka91_91title SET book_speak = :new_book_speak WHERE tripitaka91_title = :tripitaka91_title";
                $stmt_update = $conn->prepare($sql_update);
                $stmt_update->bindParam(':new_book_speak', $new_book_speak, PDO::PARAM_STR);
                $stmt_update->bindParam(':tripitaka91_title', $row_title['tripitaka91_title'], PDO::PARAM_STR);
                $stmt_update->execute();

                $folderPath = 'sounds/' . 'title_' . str_replace('.', '', $row_title['tripitaka91_code']); // สร้างเส้นทางไปยังโฟลเดอร์     
                if (file_exists($folderPath) && is_dir($folderPath)) {
                    $files = glob($folderPath . '/*.mp3'); // ดึงรายชื่อไฟล์ในโฟลเดอร์
                    foreach ($files as $file) {
                        if (is_file($file)) {
                            unlink($file); // ลบไฟล์ทั้งหมดในโฟลเดอร์
                        }
                    }
                    //echo 'Deleted all files in the folder: ' . $folderPath;
                } else {
                    //echo 'Folder not found: ' . $folderPath;
                }
            }
        }

        // ค้นหาข้อมูลจากตาราง tripitaka91_91book_line
        $sql_tripitaka = "SELECT book_id, book_pages, book_lines FROM tripitaka91_91book_line WHERE book_detail LIKE :wordsearch";
        $stmt_tripitaka = $conn->prepare($sql_tripitaka);        
        $stmt_tripitaka->bindValue(':wordsearch', '%' . $wordsearch . '%', PDO::PARAM_STR);
        $stmt_tripitaka->execute();
        $response = $stmt_tripitaka->fetchAll(PDO::FETCH_ASSOC);    
        
        if (!empty($response)) {

            $folderCreator = new FolderCreator();
            // ตรวจสอบและบันทึกข้อมูลลงในตาราง log_speak_result
            foreach ($response as $row) {
                // ตรวจสอบว่ามีข้อมูลในตาราง log_speak_result หรือไม่
                $sql_check_existing = "SELECT book_speak FROM log_speak_result WHERE book_id = :book_id AND book_pages = :book_pages AND book_lines = :book_lines FOR UPDATE";
                $stmt_check_existing = $conn->prepare($sql_check_existing);
                $stmt_check_existing->bindParam(':book_id', $row['book_id'], PDO::PARAM_INT);
                $stmt_check_existing->bindParam(':book_pages', $row['book_pages'], PDO::PARAM_INT);
                $stmt_check_existing->bindParam(':book_lines', $row['book_lines'], PDO::PARAM_INT);
                $stmt_check_existing->execute();
                $existing_data = $stmt_check_existing->fetch(PDO::FETCH_ASSOC);

                if ($existing_data) {
                    // มีข้อมูลอยู่แล้ว
                    $existing_book_speak = $existing_data['book_speak'];
                    
                    // ตรวจสอบว่าข้อมูลที่จะอัปเดตตรงกับข้อมูลที่มีอยู่หรือไม่
                    if (strpos($existing_book_speak, $book_speak) === false) {
                        // ไม่มีข้อความเดียวกัน ทำการอัปเดต
                        $new_book_speak = $existing_book_speak . ', ' . $book_speak;
                        
                        $sql_update = "UPDATE log_speak_result SET book_speak = :new_book_speak WHERE book_id = :book_id AND book_pages = :book_pages AND book_lines = :book_lines";
                        $stmt_update = $conn->prepare($sql_update);
                        $stmt_update->bindParam(':new_book_speak', $new_book_speak, PDO::PARAM_STR);
                        $stmt_update->bindParam(':book_id', $row['book_id'], PDO::PARAM_INT);
                        $stmt_update->bindParam(':book_pages', $row['book_pages'], PDO::PARAM_INT);
                        $stmt_update->bindParam(':book_lines', $row['book_lines'], PDO::PARAM_INT);
                        $stmt_update->execute();
                    } else {
                        // มีข้อความเดียวกัน ไม่ต้องทำการอัปเดต
                        continue;
                    }
                } else {
                    // ไม่มีข้อมูลอยู่ในตาราง log_speak_result ให้ทำการเพิ่มข้อมูล
                    $sql_insert = "INSERT INTO log_speak_result (book_id, book_pages, book_lines, book_speak) VALUES (:book_id, :book_pages, :book_lines, :book_speak)";
                    $stmt_insert = $conn->prepare($sql_insert);
                    $stmt_insert->bindParam(':book_id', $row['book_id'], PDO::PARAM_INT);
                    $stmt_insert->bindParam(':book_pages', $row['book_pages'], PDO::PARAM_INT);
                    $stmt_insert->bindParam(':book_lines', $row['book_lines'], PDO::PARAM_INT);
                    $stmt_insert->bindParam(':book_speak', $book_speak, PDO::PARAM_STR);
                    $stmt_insert->execute();
                }

                // ดำเนินการลบโฟลเดอร์ Books                
                $rootFolder = 'sounds/books_' . $row['book_id'] . '/pages_' . $row['book_pages'];
                if (file_exists($rootFolder) && is_dir($rootFolder)) {
                    $folderCreator->deleteMp3Files($rootFolder);
                    //echo 'Deleted all MP3 files in the folder: ' . $rootFolder;
                } else {
                    //echo 'Folder not found: ' . $rootFolder;
                }

                // ดำเนินการลบโฟลเดอร์ Search                
                $rootFolder = 'sounds/search_' . $row['book_id'] . '/pages_' . $row['book_pages'];
                if (file_exists($rootFolder) && is_dir($rootFolder)) {
                    $folderCreator->deleteMp3Files($rootFolder);
                    //echo 'Deleted all MP3 files in the folder: ' . $rootFolder;
                } else {
                    //echo 'Folder not found: ' . $rootFolder;
                }

            }
        }

        // ยืนยัน Transaction
        $conn->commit();
        echo json_encode([
            'success' => true,
            'message' => 'บันทึกข้อมูลสำเร็จ'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'คุณยังไม่ป้อนคำค้นหา',           
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
    
} catch (Exception $e) {
    // ยกเลิก Transaction ในกรณีที่เกิดข้อผิดพลาด
    $conn->rollBack();
    echo json_encode([
        'success' => false,
        'message' => 'ไม่สามารถดึงข้อมูลได้: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
