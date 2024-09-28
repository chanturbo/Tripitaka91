import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

class ImageCaptureService {
  Future<void> captureAndSharePng(GlobalKey globalKey) async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // บันทึกภาพไปยังโฟลเดอร์ชั่วคราว
      final directory = (await getTemporaryDirectory()).path;
      File imgFile = File('$directory/card_image.png');
      await imgFile.writeAsBytes(pngBytes);

      // แชร์ไฟล์รูปภาพ (แก้ไขเป็น shareXFiles)
      await Share.shareXFiles([XFile(imgFile.path)], text: 'Here is the card!');
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }
}
