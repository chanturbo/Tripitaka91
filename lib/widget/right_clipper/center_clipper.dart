import 'package:flutter/material.dart';

class DoubleTriangleRectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // สร้างขอบมนด้านซ้าย
    path.lineTo(5.0, 0.0); // ด้านบน
    path.quadraticBezierTo(0.0, 0.0, 0.0, 5.0); // โค้งด้านซ้ายบน
    path.lineTo(0.0, size.height - 5.0); // ด้านซ้ายล่างบน
    path.quadraticBezierTo(
        0.0, size.height, 5.0, size.height); // โค้งด้านซ้ายล่าง

    // สร้างขอบมนด้านขวา
    path.lineTo(size.width - 5.0, size.height); // ด้านล่าง
    path.quadraticBezierTo(size.width, size.height, size.width,
        size.height - 5.0); // โค้งด้านขวาล่าง
    path.lineTo(size.width, 5.0); // ด้านขวาล่างบน
    path.quadraticBezierTo(
        size.width, 0.0, size.width - 5.0, 0.0); // โค้งด้านขวาบน

    path.close(); // ปิดรูปทรง

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
