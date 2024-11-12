import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/screen/respond_screen.dart';
import 'package:tripitaka91/utils/constants/text_strings.dart';
import 'package:tripitaka91/widget/my_home_desktop.dart';
import 'package:tripitaka91/widget/my_home_mobile.dart';
import 'package:tripitaka91/widget/my_home_tablet.dart';

class MyHomePage extends StatefulWidget {
  final bool online;
  const MyHomePage({super.key, required this.online});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
