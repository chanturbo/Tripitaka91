import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/theme/theme.dart';
import 'package:tripitaka91/widget/my_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'พระไตรปิฎกและอรรถกถาแปลชุด 91 เล่ม ฉบับ มมร. (เล่มสีน้ำเงิน)',
      themeMode: ThemeMode.light,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}
