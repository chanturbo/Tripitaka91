import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripitaka91/utils/theme/theme.dart';
import 'package:tripitaka91/utils/theme/theme_provider.dart';
import 'package:tripitaka91/widget/my_home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const grayscaleFilter = ColorFilter.matrix(<double>[
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
    final isGrayscale = context.watch<ThemeProvider>().isGrayscale;

    return ColorFiltered(
      colorFilter: isGrayscale
          ? grayscaleFilter
          : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
      child: MaterialApp(
        title: 'พระไตรปิฎกและอรรถกถาแปลชุด 91 เล่ม ฉบับ มมร. (เล่มสีน้ำเงิน)',
        themeMode: ThemeMode.light,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
      ),
    );
  }
}
