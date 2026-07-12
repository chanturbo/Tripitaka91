// image_capture_service.dart

import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/img_service/web_download.dart';

class ImageCaptureService {
  Future<void> captureAndSharePng(Uint8List capturedImage, String title,
      String bookid, String pageid, String lineid) async {
    try {
      String link = '$tURLmain$bookid-$pageid-$lineid.htm';
      String replaceTitle = '$bookid/$pageid/$lineid';
      title = title.replaceAll(replaceTitle, '');

      if (kIsWeb) {
        // เว็บไม่มีสิทธิ์เข้าถึงไฟล์ระบบ ดาวน์โหลดรูปเป็นไฟล์แทนการแชร์
        _downloadPngOnWeb(capturedImage, bookid, pageid, lineid);
        return;
      }

      // วิธีการสำหรับแพลตฟอร์มอื่น ๆ (iOS, Android, ฯลฯ)
      final directory = (await getApplicationDocumentsDirectory()).path;
      io.File imgFile = io.File('$directory/tripitaka91_img.png');
      await imgFile.writeAsBytes(capturedImage);

      // แชร์ไฟล์รูปภาพ
      await SharePlus.instance.share(ShareParams(
          files: [XFile(imgFile.path)],
          text:
              '$title เล่ม $bookid หน้า $pageid บรรทัด $lineid อ่านรายละเอียด -> $link'));
    } catch (e) {
      // คุณสามารถจัดการข้อผิดพลาดได้ตามต้องการ
      // ignore: avoid_print
      print('Error in ImageCaptureService: $e');
    }
  }

  void _downloadPngOnWeb(
      Uint8List capturedImage, String bookid, String pageid, String lineid) {
    downloadPngOnWeb(
        capturedImage, 'tripitaka91_$bookid-$pageid-$lineid.png');
  }

  Future<String?> captureAndSavePng(Uint8List capturedImage, String bookid,
      String pageid, String lineid) async {
    try {
      if (kIsWeb) {
        _downloadPngOnWeb(capturedImage, bookid, pageid, lineid);
        return null;
      }

      // สร้างไฟล์รูปภาพใน ApplicationDocumentsDirectory
      final directory = await getApplicationDocumentsDirectory();
      final imgFilePath = '${directory.path}/tripitaka91_img.png';
      io.File imgFile = io.File(imgFilePath);
      await imgFile.writeAsBytes(capturedImage);

      // คืนค่า path ของไฟล์ที่บันทึก
      return imgFilePath;
    } catch (e) {
      // จัดการข้อผิดพลาด
      // ignore: avoid_print
      print('Error in ImageCaptureService: $e');

      return null;
    }
  }
}
