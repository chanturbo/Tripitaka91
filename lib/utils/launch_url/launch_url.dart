import 'package:url_launcher/url_launcher.dart';

// เดิมแต่ละไฟล์ใน lib/features/book/ มีเมธอดนี้แยกกันเองแบบ byte-for-byte
// (bookshow_title.dart, show_title_list.dart, show_title_sub.dart) รวมไว้
// เป็นที่เดียวเพื่อไม่ให้ต้องแก้ซ้ำหลายจุดเวลามีการเปลี่ยนพฤติกรรม
Future<void> openLinkInNewTab(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'ไม่สามารถเปิดลิงก์: $url';
  }
}
