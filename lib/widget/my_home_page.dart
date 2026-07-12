import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripitaka91/widget/screen/respond_screen.dart';
import 'package:tripitaka91/utils/constants/text_strings.dart';
import 'package:tripitaka91/widget/my_home_desktop.dart';
import 'package:tripitaka91/widget/my_home_mobile.dart';
import 'package:tripitaka91/widget/my_home_tablet.dart';

class MyHomePage extends StatefulWidget {
  final bool online;

  const MyHomePage({
    super.key,
    required this.online,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _requestPermissionsIfFirstRun();
  }

  Future<void> _requestPermissionsIfFirstRun() async {
    // เข้าถึง SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // เช็คว่ามีการบันทึกว่ารันครั้งแรกหรือไม่
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      // ขอ permission สำหรับการเขียน storage
      // permission_handler has no macOS implementation, so this throws
      // MissingPluginException there — catch it rather than crash.
      try {
        PermissionStatus status = await Permission.storage.request();

        if (status.isGranted) {
          debugPrint("Storage permission granted");
        } else {
          debugPrint("Storage permission denied");
        }
      } catch (e) {
        debugPrint("Storage permission request unavailable: $e");
      }

      // บันทึกว่าแอปนี้ได้รันครั้งแรกไปแล้ว
      await prefs.setBool('isFirstRun', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayoutClass(
        mobileView: MyHomeMobile(
          title: '${TTexts.appTitle} Mobile',
          online: widget.online,
        ),
        tabletView: MyHomeTablet(
          title: '${TTexts.appTitle} Tablet',
          online: widget.online,
        ),
        desktopView: MyHomeDesktop(
          title: '${TTexts.appTitle} Desktop',
          online: widget.online,
        ),
      ),
    );
  }
}
