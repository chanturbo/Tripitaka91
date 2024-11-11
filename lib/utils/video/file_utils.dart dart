import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  // ฟังก์ชันดาวน์โหลดไฟล์ mp3 พร้อมตั้งชื่อใหม่ก่อนบันทึก
  Future<File> downloadMp3(String url, String newFileName) async {
    final response = await http.get(Uri.parse(url));
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$newFileName.mp3');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }
}
