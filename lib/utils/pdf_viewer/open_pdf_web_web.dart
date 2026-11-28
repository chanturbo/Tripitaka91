import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// เปิด PDF ในแท็บใหม่ของเบราว์เซอร์ (ส่วนใหญ่แสดง PDF ในตัวได้เลยโดยไม่ต้อง
/// ดาวน์โหลด) แปลง bytes เป็น Blob แบบเดียวกับ web_download_web.dart แต่ใช้
/// window.open แทน AnchorElement.click เพราะต้องการ "เปิดดู" ไม่ใช่ "ดาวน์โหลด"
void openPdfBytesOnWeb(Uint8List bytes, String fileName) {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
  // ไม่ revoke object URL ทันที เพราะแท็บใหม่ที่เพิ่งเปิดยังต้องใช้ URL นี้โหลด
  // เนื้อหาอยู่ (revoke ทันทีอาจทำให้แท็บใหม่เห็นหน้าว่าง) ปล่อยให้เบราว์เซอร์
  // คืนหน่วยความจำเองตอนปิดแท็บ/รีโหลดหน้า
}
