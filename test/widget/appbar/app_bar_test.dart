import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripitaka91/utils/providers/online_speech_provider.dart';
import 'package:tripitaka91/utils/providers/user_provider.dart';
import 'package:tripitaka91/widget/appbar/app_bar.dart';

void main() {
  Future<void> pumpAppBarAtWidth(
    WidgetTester tester,
    double width, {
    required bool isTablet,
    required bool isDesktop,
  }) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => OnlineSpeechProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              title: AppBarCustom(
                isTablet: isTablet,
                isDesktop: isDesktop,
                online: true,
              ),
              actions: const [
                IconButton(icon: Icon(Icons.person), onPressed: null),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('does not overflow at the narrow end of the tablet breakpoint', (
    tester,
  ) async {
    await pumpAppBarAtWidth(tester, 601, isTablet: true, isDesktop: false);

    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow at the wide end of the tablet breakpoint', (
    tester,
  ) async {
    await pumpAppBarAtWidth(tester, 900, isTablet: true, isDesktop: false);

    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow on desktop', (tester) async {
    await pumpAppBarAtWidth(tester, 1200, isTablet: false, isDesktop: true);

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'search box stretches to the trailing edge next to the account button',
    (tester) async {
      await pumpAppBarAtWidth(tester, 900, isTablet: true, isDesktop: false);

      final searchBoxRect = tester.getRect(
        find
            .descendant(
              of: find.byType(AppBarCustom),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      final appBarCustomRect = tester.getRect(find.byType(AppBarCustom));

      expect(searchBoxRect.right, closeTo(appBarCustomRect.right, 1));
    },
  );
}
