import 'package:flutter/material.dart';

class ResponsiveLayoutClass extends StatelessWidget {
  const ResponsiveLayoutClass(
      {super.key,
      required this.mobileView,
      required this.tabletView,
      required this.desktopView});

  final Widget mobileView;
  final Widget tabletView;
  final Widget desktopView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if ((constraints.maxWidth <= 600) || (constraints.maxHeight <= 650)) {
            return mobileView;
          } else if (constraints.maxWidth > 600 &&
              constraints.maxWidth <= 900) {
            return tabletView;
          } else {
            return desktopView;
          }
        },
      ),
    );
  }
}
