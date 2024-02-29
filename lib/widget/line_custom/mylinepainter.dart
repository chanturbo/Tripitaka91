import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';

class MyVerticalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = TColors.grey // สีของเส้น
      ..strokeCap = StrokeCap.round // รูปแบบของปลายเส้น
      ..strokeWidth = 1.0; // ความหนาของเส้น

    final Offset start = Offset(size.width / 2, 0); // จุดเริ่มต้น
    final Offset end = Offset(size.width / 2, size.height); // จุดสิ้นสุด

    canvas.drawLine(start, end, paint); // วาดเส้นแนวตั้ง
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyHorizontalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = TColors.black // สีของเส้น
      ..strokeCap = StrokeCap.round // รูปแบบของปลายเส้น
      ..strokeWidth = 1.0; // ความหนาของเส้น

    final Offset start = Offset(0, size.height / 2); // จุดเริ่มต้น
    final Offset end = Offset(size.width, size.height / 2); // จุดสิ้นสุด

    canvas.drawLine(start, end, paint); // วาดเส้นแนวนอน
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = TColors.grey // สีของเส้น
      ..strokeCap = StrokeCap.round // รูปแบบของปลายเส้น
      ..strokeWidth = 2.0; // ความหนาของเส้น

    final Offset start = Offset(0, size.height / 2); // จุดเริ่มต้น
    final Offset end = Offset(size.width, size.height / 2); // จุดสิ้นสุด

    canvas.drawLine(start, end, paint); // วาดเส้นตรง
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
