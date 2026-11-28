import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tripitaka91/utils/pdf_viewer/open_pdf_web.dart';

/// เปิดไฟล์ PDF ที่ bundle มากับแอป (ใน assets/pdf/) ด้วยแอปดู PDF ของเครื่อง
///
/// บนเว็บไม่มี path_provider (ไม่มี temp dir ให้เขียนไฟล์) และไม่มี open_filex
/// (ไม่มี native app ให้สั่งเปิด) จึงแปลง bytes เป็น Blob แล้วเปิดในแท็บใหม่แทน
/// (เบราว์เซอร์ส่วนใหญ่แสดง PDF ได้เลยในตัว) ส่วนแพลตฟอร์มอื่นยังคงคัดลอก asset
/// ไปไว้ที่ temporary directory ก่อน (ครั้งเดียวต่อไฟล์ ครั้งถัดไปใช้ไฟล์เดิมที่
/// คัดลอกไว้) แล้วค่อยส่ง path นั้นให้แอปภายนอกเปิด
Future<void> openAssetPdf(String assetFileName) async {
  final data = await rootBundle.load('assets/pdf/$assetFileName');
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  if (kIsWeb) {
    openPdfBytesOnWeb(bytes, assetFileName);
    return;
  }

  final Directory tempDir = await getTemporaryDirectory();
  final File file = File('${tempDir.path}/$assetFileName');

  if (!await file.exists()) {
    await file.writeAsBytes(bytes);
  }

  await OpenFilex.open(file.path);
}
