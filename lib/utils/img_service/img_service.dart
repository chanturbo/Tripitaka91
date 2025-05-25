// image_capture_service.dart

import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
// สำหรับการใช้งานเว็บ
// ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html; // ไม่ควรใช้ในแพลตฟอร์มอื่นนอกจากเว็บ

class ImageCaptureService {
  Future<void> captureAndSharePng(Uint8List capturedImage, String title,
      String bookid, String pageid, String lineid) async {
    try {
      String link = '$tURLmain$bookid-$pageid-$lineid.htm';
      String replaceTitle = '$bookid/$pageid/$lineid';
      replaceTitle = replaceTitle.replaceAll(title, replaceTitle);
      // ตรวจสอบว่าเป็น iPhone หรือ iPad หรือไม่
      // final userAgent = html.window.navigator.userAgent;
      // final isIPhone = userAgent.contains('iPhone');
      // final isIPad = userAgent.contains('iPad');

      // if ((isIPhone) || (isIPad)) {
      //   // วิธีการสำหรับแพลตฟอร์มอื่น ๆ (iOS, Android, ฯลฯ)
      //   final directory = (await getTemporaryDirectory()).path;
      //   io.File imgFile = io.File('$directory/tripitaka91_img.png');
      //   await imgFile.writeAsBytes(capturedImage);

      //   // แชร์ไฟล์รูปภาพ
      //   await Share.shareXFiles([XFile(imgFile.path)],
      //       text: 'อ่านเนื้อความเต็ม $link');
      // } else if (kIsWeb) {
      //   // วิธีการสำหรับเว็บ
      //   final blob = html.Blob([capturedImage], 'image/png');
      //   final url = html.Url.createObjectUrlFromBlob(blob);
      //   // ignore: unused_local_variable
      //   final anchor = html.AnchorElement(href: url)
      //     ..setAttribute('download', 'tripitaka91_$bookid-$pageid-$lineid.png')
      //     ..click();
      //   html.Url.revokeObjectUrl(url);
      // } else {
      // วิธีการสำหรับแพลตฟอร์มอื่น ๆ (iOS, Android, ฯลฯ)
      final directory = (await getApplicationDocumentsDirectory()).path;
      io.File imgFile = io.File('$directory/tripitaka91_img.png');
      await imgFile.writeAsBytes(capturedImage);

      // แชร์ไฟล์รูปภาพ
      await Share.shareXFiles([XFile(imgFile.path)],
          text:
              '$replaceTitle เล่ม $bookid หน้า $pageid บรรทัด $lineid อ่านรายละเอียด -> $link');
      // }
    } catch (e) {
      // คุณสามารถจัดการข้อผิดพลาดได้ตามต้องการ
      // ignore: avoid_print
      print('Error in ImageCaptureService: $e');
    }
  }

  Future<String?> captureAndSavePng(Uint8List capturedImage, String bookid,
      String pageid, String lineid) async {
    try {
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
