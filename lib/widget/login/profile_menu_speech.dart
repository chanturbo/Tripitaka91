import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';
import 'package:tripitaka91/widget/login/profile_menu.dart';

class TProfileMenuSpeechFuture extends StatelessWidget {
  const TProfileMenuSpeechFuture({
    super.key,
    required this.onPressed,
    required this.title,
    required this.valueFuture,
    this.icon = Icons.record_voice_over_outlined,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String title;
  final Future<String> valueFuture; // แก้เป็น Future<String>

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: valueFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TProfileInfoRow(
            icon: icon,
            title: title,
            value: const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (snapshot.hasError) {
          return TProfileInfoRow(
            icon: icon,
            title: title,
            value: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snapshot.error}'),
          );
        } else {
          final value = snapshot.data ?? '0';
          saveValueSpeech(int.parse(value));
          return TProfileInfoRow(
            icon: icon,
            title: title,
            value: Text('$value รายการ'),
          );
        }
      },
    );
  }
}
