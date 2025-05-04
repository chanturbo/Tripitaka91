import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/theme/theme.dart';
import 'package:tripitaka91/widget/my_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isGrayscale = false;

  // กรองสีขาว-ดำ
  final grayscaleFilter = const ColorFilter.matrix(<double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: _isGrayscale
          ? grayscaleFilter
          : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
      child: MaterialApp(
        title: 'พระไตรปิฎกและอรรถกถาแปลชุด 91 เล่ม ฉบับ มมร. (เล่มสีน้ำเงิน)',
        themeMode: ThemeMode.light,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: MyHomePage(
          onToggleGrayscale: () {
            setState(() {
              _isGrayscale = !_isGrayscale;
            });
          },
          isGrayscale: _isGrayscale,
        ),
      ),
    );
  }
}
