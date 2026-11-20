import 'dart:math';

import 'package:flutter/material.dart';

/// วงกงล้อธรรมจักร 8 ก้าน วาดด้วย CustomPaint ให้หน้าตาตรงกับโลโก้ที่ใช้ใน
/// โปรเจค DharmaTimeStamp (LOGO_SVG ใน web/src/layout.php) — เวกเตอร์จึงคมชัด
/// ทุกขนาดจอโดยไม่ต้องพึ่งไฟล์รูปภาพ
class DharmaWheelIcon extends StatelessWidget {
  final double size;
  final Color color;

  const DharmaWheelIcon({
    super.key,
    this.size = 28,
    this.color = const Color(0xFF9A5B1E),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DharmaWheelPainter(color),
    );
  }
}

class _DharmaWheelPainter extends CustomPainter {
  final Color color;

  _DharmaWheelPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // อิงสัดส่วนจาก viewBox 40x40 ของต้นฉบับ (circle r=16, hub r=4, stroke 2)
    final scale = size.width / 40;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = 16 * scale;
    final hubRadius = 4 * scale;

    canvas.drawCircle(center, outerRadius, paint);
    canvas.drawCircle(center, hubRadius, paint);

    for (int i = 0; i < 8; i++) {
      final angle = i * (pi / 4);
      final spokeEnd = center + Offset(cos(angle), sin(angle)) * outerRadius;
      canvas.drawLine(center, spokeEnd, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DharmaWheelPainter oldDelegate) =>
      oldDelegate.color != color;
}
