import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/screen/respond_screen.dart';
import 'package:tripitaka91/utils/constants/text_strings.dart';
import 'package:tripitaka91/widget/my_home_desktop.dart';
import 'package:tripitaka91/widget/my_home_mobile.dart';
import 'package:tripitaka91/widget/my_home_tablet.dart';

class MyHomePageOnline extends StatefulWidget {
  const MyHomePageOnline({super.key});

  @override
  State<MyHomePageOnline> createState() => _MyHomePageOnlineState();
}

class _MyHomePageOnlineState extends State<MyHomePageOnline> {
  final bool online = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayoutClass(
        mobileView: MyHomeMobile(
          title: '${TTexts.appTitle} Mobile',
          online: online,
        ),
        tabletView: MyHomeTablet(
          title: '${TTexts.appTitle} Tablet',
          online: online,
        ),
        desktopView: MyHomeDesktop(
          title: '${TTexts.appTitle} Desktop',
          online: online,
        ),
      ),
    );
  }
}
