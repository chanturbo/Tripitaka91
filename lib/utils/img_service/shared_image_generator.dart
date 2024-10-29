// shared_image_generator.dart

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/img_service/img_service.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';

class SharedImageGenerator {
  final ScreenshotController screenshotController;
  final ImageCaptureService
      imageCaptureService; // เพิ่มตัวแปรสำหรับ ImageCaptureService

  SharedImageGenerator()
      : screenshotController = ScreenshotController(),
        imageCaptureService =
            ImageCaptureService(); // สร้างอินสแตนซ์ของ ImageCaptureService

  Future<void> generateAndShare({
    required BuildContext context,
    required String bookTitle,
    required String bookid,
    required String pageid,
    required String lineid,
    required String bookBlue,
    required String bookRed,
  }) async {
    String strReplaceBookBlue = "$bookid/$pageid/$lineid";
    // สร้างคอนเทนเนอร์ตามที่คุณมีในฟังก์ชันเดิม
    final container = SizedBox(
      width: 360, // กำหนดความกว้างที่คงที่
      child: Card(
        margin: const EdgeInsets.all(5),
        shadowColor: TColors.white,
        color: TColors.white,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ปรับความสูงตามเนื้อหา
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    text: bookTitle.replaceAll(strReplaceBookBlue, ''),
                    style: TextStyle(
                      fontFamily: 'THSarabunNew',
                      fontSize: 30,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ClipPath(
                      clipper: DoubleTriangleRectangleClipper(),
                      child: Container(
                        padding: const EdgeInsets.all(3.0),
                        color: Colors.blue, // Change color as needed
                        child: Center(
                          child: ATextLabelSmall(
                            text: 'เล่มสีน้ำเงิน $bookBlue',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ClipPath(
                      clipper: DoubleTriangleRectangleClipper(),
                      child: Container(
                        padding: const EdgeInsets.all(3.0),
                        color: Colors.red, // Change color as needed
                        child: Center(
                          child: ATextDiskplaySmall(text: 'เล่มสีแดง $bookRed'),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'สรุปเนื้อความจากพระไตรปิฎกและอรรถกถาแปล ชุด 91 เล่ม',
                  style: TextStyle(
                      fontFamily: 'THSarabunNew',
                      fontSize: 20,
                      color: Colors.grey[800]),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ฉบับมหามกุฏราชวิทยาลัย | อ่านเนื้อความเต็ม -> ',
                  style: TextStyle(
                      fontFamily: 'THSarabunNew',
                      fontSize: 20,
                      color: Colors.grey[800]),
                ),
              ),
              // const Align(
              //   alignment: Alignment.centerLeft,
              //   child: Text(
              //     'อ่านเนื้อความเต็ม -> ',
              //     style: TextStyle(
              //         fontFamily: 'Roboto', fontSize: 16, color: Colors.black),
              //   ),
              // ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$tURLmain$bookid-$pageid-$lineid.htm',
                  style: const TextStyle(
                      fontFamily: 'Roboto', fontSize: 16, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // ดักจับภาพจากวิดเจ็ต
      final capturedImage = await screenshotController.captureFromWidget(
        InheritedTheme.captureAll(
          context,
          Material(child: container),
        ),
        pixelRatio: 2.0,
      );

      // เรียกใช้ฟังก์ชันแชร์จาก ImageCaptureService
      await imageCaptureService.captureAndSharePng(
          capturedImage, bookid, pageid, lineid);
    } catch (e) {
      // คุณสามารถจัดการข้อผิดพลาดได้ตามต้องการ
      // ignore: avoid_print
      print('Error capturing and sharing image: $e');
    }
  }
}
