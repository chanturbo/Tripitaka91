import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ เพิ่มตรงนี้
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
  bool _isLoading = true; // ✅ ใช้โหลด SharedPreferences

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
  void initState() {
    super.initState();
    _loadGrayscaleSetting();
  }

  Future<void> _loadGrayscaleSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGrayscale =
          prefs.getBool('isGrayscale') ?? false; // default: ปิดโหมดขาวดำ
      _isLoading = false;
    });
  }

  Future<void> _toggleGrayscale() async {
    setState(() {
      _isGrayscale = !_isGrayscale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGrayscale', _isGrayscale);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // ✅ รอโหลดค่า SharedPreferences ก่อน
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

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
          onToggleGrayscale: _toggleGrayscale,
          isGrayscale: _isGrayscale,
        ),
      ),
    );
  }
}
