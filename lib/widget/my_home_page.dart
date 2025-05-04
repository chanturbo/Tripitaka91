import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/screen/respond_screen.dart';
import 'package:tripitaka91/utils/constants/text_strings.dart';
import 'package:tripitaka91/widget/my_home_desktop.dart';
import 'package:tripitaka91/widget/my_home_mobile.dart';
import 'package:tripitaka91/widget/my_home_tablet.dart';

class MyHomePage extends StatefulWidget {
  final VoidCallback onToggleGrayscale;
  final bool isGrayscale;

  const MyHomePage({
    super.key,
    required this.onToggleGrayscale,
    required this.isGrayscale,
  });

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
          onToggleGrayscale: widget.onToggleGrayscale,
          isGrayscale: widget.isGrayscale,
        ),
        tabletView: MyHomeTablet(
          title: '${TTexts.appTitle} Tablet',
          onToggleGrayscale: widget.onToggleGrayscale,
          isGrayscale: widget.isGrayscale,
        ),
        desktopView: MyHomeDesktop(
          title: '${TTexts.appTitle} Desktop',
          onToggleGrayscale: widget.onToggleGrayscale,
          isGrayscale: widget.isGrayscale,
        ),
      ),
    );
  }
}
