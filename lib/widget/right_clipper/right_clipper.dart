import 'package:flutter/material.dart';

class RightTriangleRectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width - 15.0, 0.0); // เริ่มต้นจากตำแหน่งด้านบนของเส้นตรง
    path.quadraticBezierTo(
        size.width, 0.0, size.width, 15.0); // เส้นโค้งด้านขวาบน
    path.lineTo(size.width, size.height - 15.0); // เส้นตรงด้านขวาล่างบน
    path.quadraticBezierTo(size.width, size.height, size.width - 15.0,
        size.height); // เส้นโค้งด้านขวาล่าง
    path.lineTo(0.0, size.height); // เส้นตรงด้านล่าง
    path.close(); // ปิดรูปทรง

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
