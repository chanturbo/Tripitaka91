import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:saver_gallery/saver_gallery.dart';

class VideoUtils {
  // ฟังก์ชันสร้าง mp4 จากภาพและเสียง
  Future<void> createMp4(
      String imagePath, String audioPath, String outputPath) async {
    final command = '-loop 1 -i $imagePath -i $audioPath -c:v libx264 -c:a aac '
        '-shortest -pix_fmt yuv420p $outputPath';
    await FFmpegKit.execute(command);
  }

  // ฟังก์ชันบันทึก mp4 ลงแกลเลอรี
  Future<void> saveVideoToGallery(String videoPath) async {
    try {
      await SaverGallery.saveFile(
        file: videoPath,
        name: 'tripitaka91_video.mp4',
        androidRelativePath: "Movies",
        androidExistNotSave: true,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
    // print('Video saved to gallery');
  }
}
