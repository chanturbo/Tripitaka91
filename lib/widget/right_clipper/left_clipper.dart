import 'package:flutter/material.dart';

class LeftTriangleRectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(15.0, 0.0); // เริ่มต้นจากตำแหน่งด้านบนของเส้นตรง
    path.quadraticBezierTo(0.0, 0.0, 0.0, 15.0); // เส้นโค้งด้านซ้ายบน
    path.lineTo(0.0, size.height - 15.0); // เส้นตรงด้านซ้ายล่างบน
    path.quadraticBezierTo(
        0.0, size.height, 15.0, size.height); // เส้นโค้งด้านซ้ายล่าง
    path.lineTo(size.width, size.height); // เส้นตรงด้านล่าง
    path.lineTo(size.width, 0.0); // เส้นตรงด้านขวา
    path.close(); // ปิดรูปทรง

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
