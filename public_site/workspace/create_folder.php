<?php

class FolderCreator {
    public function createFolder($inputString) {
        // แยกค่าจาก inputString
        $values = explode('-', $inputString);

        // ตรวจสอบว่ามีค่าเพียงพอหรือไม่
        if (count($values) != 3) {
            die('Invalid input format. Please provide three values separated by hyphens.');
        }

        // สร้างโฟลเดอร์
        $rootFolder = 'books_' . $values[0];
        $subFolder = 'pages_' . $values[1];
        $folderPath = 'sounds/'.$rootFolder . '/' . $subFolder;

        if (!file_exists($folderPath) && !is_dir($folderPath)) {
            mkdir($folderPath, 0777, true);
        } 
        
        return $folderPath; // ส่งค่า path กลับ
    }

    
    public function deleteMp3Files($folderPath) {
        // ตรวจสอบว่าโฟลเดอร์มีอยู่หรือไม่
        if (!file_exists($folderPath) || !is_dir($folderPath)) {
            die('Folder not found.');
        }

        // ลบไฟล์ *.mp3 ทั้งหมดภายในโฟลเดอร์
        $files = glob($folderPath . '/*.mp3');
        foreach ($files as $file) {
            if (is_file($file)) {
                unlink($file);
            }
        }
    }

    public function deleteSingleMp3File($filePath) {
        // ตรวจสอบว่าไฟล์มีอยู่และเป็นไฟล์ .mp3 หรือไม่
        if (file_exists($filePath) && is_file($filePath) && pathinfo($filePath, PATHINFO_EXTENSION) === 'mp3') {
            unlink($filePath);
        } else {
            die('File not found or not an mp3 file.');
        }
    }

    
}

class FolderCreatorTmp {
    public function createFolderTmp($inputString) {

        // สร้างโฟลเดอร์
        $rootFolder = 'tmp';
        $folderPath = 'sounds/'.$rootFolder;

        if (!file_exists($folderPath) && !is_dir($folderPath)) {
            mkdir($folderPath, 0777, true);
        } 
        
        return $folderPath; // ส่งค่า path กลับ
    }
}

class FolderCreatorDict {
    public function createFolderDict($inputString) {

        // สร้างโฟลเดอร์
        $rootFolder = 'dict';
        $folderPath = 'sounds/'.$rootFolder;

        if (!file_exists($folderPath) && !is_dir($folderPath)) {
            mkdir($folderPath, 0777, true);
        } 
        
        return $folderPath; // ส่งค่า path กลับ
    }
}

class FolderCreatorSearch {
    public function createFolderSearch($inputString) {
        // แยกค่าจาก inputString
        $values = explode('-', $inputString);

        // ตรวจสอบว่ามีค่าเพียงพอหรือไม่
        if (count($values) != 3) {
            die('Invalid input format. Please provide three values separated by hyphens.');
        }

        // สร้างโฟลเดอร์
        $rootFolder = 'search_' . $values[0];
        $subFolder = 'pages_' . $values[1];
        $folderPath = 'sounds/'.$rootFolder . '/' . $subFolder;

        if (!file_exists($folderPath) && !is_dir($folderPath)) {
            mkdir($folderPath, 0777, true);
        } 
        
        return $folderPath; // ส่งค่า path กลับ
    }
}

class FolderCreatorTitle {
    public function createFolderTitle($inputString) {
        // แยกค่าจาก inputString
        $values = explode('-', $inputString);

        // สร้างโฟลเดอร์
        $rootFolder = 'title_' . $values[0];
        $folderPath = 'sounds/'.$rootFolder;

        if (!file_exists($folderPath) && !is_dir($folderPath)) {
            mkdir($folderPath, 0777, true);
        } 
        
        return $folderPath; // ส่งค่า path กลับ
    }
}

?>