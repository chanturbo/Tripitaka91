import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VideoGenerator {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  Future<String> downloadAudioFile(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/downloaded_audio.mp3';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } else {
      throw Exception("Failed to download audio file");
    }
  }

  Future<void> generateAndSaveVideo(
      String imagePath, String audioFilePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final outputPath = '${directory.path}/output_video.mp4';

      final String command =
          '-loop 1 -i $imagePath -i $audioFilePath -c:v mpeg4 -b:v 2000k -c:a aac -b:a 320k -shortest -pix_fmt yuv420p $outputPath';

      final file = File(outputPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      await _flutterFFmpeg.execute(command);

      final result = await ImageGallerySaver.saveFile(outputPath);
      if (!result['isSuccess']) {
        throw Exception("Failed to save video to gallery");
      }
    } catch (e) {
      throw Exception("Error generating video: $e");
    }
  }

  Future<void> captureAndCreateVideo(String audioUrl, String imagePath) async {
    // ดาวน์โหลดไฟล์เสียง

    final audioFilePath = await downloadAudioFile(audioUrl);

    // สร้างวิดีโอจากภาพและเสียง
    await generateAndSaveVideo(imagePath, audioFilePath);
  }
}
