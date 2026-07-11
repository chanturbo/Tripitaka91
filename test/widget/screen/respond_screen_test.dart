import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripitaka91/widget/screen/respond_screen.dart';

void main() {
  Future<void> pumpAtWidth(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ResponsiveLayoutClass(
          mobileView: const Text('mobile-view'),
          tabletView: const Text('tablet-view'),
          desktopView: const Text('desktop-view'),
        ),
      ),
    );
  }

  testWidgets('shows the mobile view at 600px and below', (tester) async {
    await pumpAtWidth(tester, 600);

    expect(find.text('mobile-view'), findsOneWidget);
    expect(find.text('tablet-view'), findsNothing);
    expect(find.text('desktop-view'), findsNothing);
  });

  testWidgets('shows the tablet view between 601px and 900px', (
    tester,
  ) async {
    await pumpAtWidth(tester, 750);

    expect(find.text('mobile-view'), findsNothing);
    expect(find.text('tablet-view'), findsOneWidget);
    expect(find.text('desktop-view'), findsNothing);
  });

  testWidgets('shows the tablet view exactly at the 900px boundary', (
    tester,
  ) async {
    await pumpAtWidth(tester, 900);

    expect(find.text('tablet-view'), findsOneWidget);
  });

  testWidgets('shows the desktop view above 900px', (tester) async {
    await pumpAtWidth(tester, 1200);

    expect(find.text('mobile-view'), findsNothing);
    expect(find.text('tablet-view'), findsNothing);
    expect(find.text('desktop-view'), findsOneWidget);
  });
}
