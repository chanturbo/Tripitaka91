import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
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
        home: const PlatformCheckerScreen(),
      ),
    );
  }
}

class PlatformCheckerScreen extends StatelessWidget {
  const PlatformCheckerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the app is running on Web, Android, or iOS
    if (kIsWeb) {
      return const WebNotSupportedScreen();
    } else if (Platform.isAndroid || Platform.isIOS || Platform.isWindows) {
      return const UnzipScreen();
    } else {
      return const UnsupportedPlatformScreen();
    }
  }
}

class UnzipScreen extends StatefulWidget {
  const UnzipScreen({super.key});

  @override
  State<UnzipScreen> createState() => _UnzipScreenState();
}

class _UnzipScreenState extends State<UnzipScreen> {
  bool isLoading = false;
  String unzipStatus = 'Idle';
  Users? usersChk;
  bool online = false;

  @override
  void initState() {
    super.initState();
    _startUnzippingProcess();
  }

  Future<void> _startUnzippingProcess() async {
    setState(() {
      isLoading = true;
      unzipStatus = 'กำลังประมวลผล...';
    });

    try {
      // Call the loadFromFuture function
      await loadFromFuture();
      usersChk = await getUsersList();

      // print('คือ $usersChk');
      setState(() {
        if (usersChk != null) {
          online = true;
        }
        unzipStatus = 'ประมวลผลสำเร็จ!';
      });
      // print(online);
      // Navigate to MyHomePage after unzip is complete
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(online: online)),
      );
    } catch (e) {
      setState(() {
        unzipStatus = 'เกิดข้อผิดพลาด!';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประมวลผลฐานข้อมูล'),
      ),
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(unzipStatus),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(unzipStatus),
                ],
              ),
      ),
    );
  }
}

Future<void> loadFromFuture() async {
  String fileName = "tripitaka91.zip";
  String dbName = "tripitaka91.db";
  String dir = (await getApplicationDocumentsDirectory()).path;

  if (Platform.isAndroid) {
    dir = dir.replaceAll('/app_flutter', '');
    await Directory('$dir/databases').create(recursive: false);
    dir = "$dir/databases";
  }

  String savePath = '$dir/$fileName';
  String dbPath = '$dir/$dbName';

  if (Platform.isWindows) {
    dir = (await getApplicationSupportDirectory()).path;
    savePath = '$dir\\$fileName';
    dbPath = '$dir\\$dbName';
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('dbPath', dbPath);

  if (await File(dbPath).exists()) {
    if (await File(savePath).exists()) {
      deleteFile(File(savePath));
    }
    // print(dbPath);
    // await Future.delayed(const Duration(seconds: 1));
  } else {
    await Future.delayed(const Duration(seconds: 2));

    if (FileSystemEntity.typeSync(savePath) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load('assets/db/$fileName');
      await writeToFile(data, savePath);

      final bytes = File(savePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = await file.content as List<int>;
          File('$dir/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('$dir/$filename').create(recursive: true);
        }
      }
      if (await File(savePath).exists()) {
        deleteFile(File(savePath));
      }
    }
  }
}

Future<void> writeToFile(ByteData data, String path) async {
  final buffer = data.buffer;
  return File(path).writeAsBytesSync(
      buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

Future<void> deleteFile(File file) async {
  try {
    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {
    // Handle errors
  }
}

class WebNotSupportedScreen extends StatelessWidget {
  const WebNotSupportedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Not Supported'),
      ),
      body: const Center(
        child: Text('Unzipping files is not supported on the web.'),
      ),
    );
  }
}

class UnsupportedPlatformScreen extends StatelessWidget {
  const UnsupportedPlatformScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsupported Platform'),
      ),
      body: const Center(
        child: Text('This platform is not supported for unzipping files.'),
      ),
    );
  }
}
