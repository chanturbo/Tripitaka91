import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/auth/authentication_service.dart';
import 'package:tripitaka91/utils/db_helper/db_helper.dart';
import 'package:tripitaka91/utils/models/rand_title.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/widget/login/login.dart';
import 'package:tripitaka91/widget/login/member_tab_show.dart';
import 'package:tripitaka91/features/book/pageviews_html.dart';

// Shared state/logic behind MyHomeMobile/MyHomeTablet/MyHomeDesktop. The
// three layouts render very different navigation UIs (drawer vs icon-rail
// vs permanent panel), so only the non-visual behavior lives here — each
// build() method stays in its own file.
mixin HomeStateMixin<T extends StatefulWidget> on State<T> {
  bool get online;
  bool get isMobileLayout;

  bool loadLastRead = false;
  List<RandTitle>? randTitle;
  String triCatage = 'โหลดข้อมูล...';
  String triTitle = 'โหลดข้อมูล...';
  String bookBlue = 'โหลดข้อมูล...';
  String bookRed = 'โหลดข้อมูล...';
  String noTitle = '1';
  String noTitleCate = '9.1';
  String triBookid = '1';
  int triPageid = 1;
  String triBookline = '1';

  late Users? usersList;
  String? book;
  String? page;
  String? line;
  late Timer homeTimer;

  final dbHelper = DatabaseHelper();
  final authService = AuthenticationService();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    getDataRandTitle();
    userOnline();
    checkArguments();
    homeTimer = Timer(const Duration(seconds: 1), onTimerFinished);
  }

  void onTimerFinished() {
    if (mounted) {
      // ทำงานก็ต่อเมื่อ widget ยังไม่ถูก dispose
      if ((book != null) && (page != null) && (line != null)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Tri91PageViewHtml(
              triBookid: book!,
              triPageid: int.parse(page!),
              triBookline: line!,
              chkSearch: '',
              isMobile: isMobileLayout,
              online: online,
            ),
          ),
        );
      }
    }
  }

  Future<void> checkLoginStatus() async {
    isLoggedIn = await authService.checkLoginStatus();
    if (!mounted) return;
    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const MemberTabShow(indexShow: 0)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  void checkArguments() {
    final uri = Uri.base;
    final Map<String, String> queryParameters = uri.queryParameters;

    setState(() {
      book = queryParameters['book'];
      page = queryParameters['page'];
      line = queryParameters['line'];
    });
  }

  @override
  void dispose() {
    homeTimer.cancel();
    logOutUser();
    super.dispose();
  }

  Future<void> logOutUser() async {
    // clearUsersList();
  }

  Future<void> userOnline() async {
    usersList = await getUsersList();
  }

  Future<void> getDataRandTitle() async {
    try {
      online
          ? randTitle = await RemoteServiceRandTitle().getRandTitleAPI()
          : randTitle = await dbHelper.getRandTitleDB();
      if (randTitle != null) {
        setState(() {
          triCatage = randTitle![0].tripitaka91Category;
          triTitle = randTitle![0].tripitaka91Title;
          bookBlue = randTitle![0].tripitaka91BookBlue;
          bookRed = randTitle![0].tripitaka91BookRed;
          triBookid = randTitle![0].tripitaka91Book.toString();
          triPageid = randTitle![0].tripitaka91Page;
          triBookline = randTitle![0].tripitaka91Line.toString();
          noTitle = randTitle![0].tripitaka91No.toString();
          noTitleCate = randTitle![0].tripitaka91Code.toString();
          loadRead();
        });
      } else {
        triCatage = 'โหลดข้อมูล...';
        triTitle = 'โหลดข้อมูล...';
        bookBlue = 'โหลดข้อมูล...';
        bookRed = 'โหลดข้อมูล...';
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  bool loadRead() {
    if (loadLastRead) {
      loadLastRead = false;
    } else {
      loadLastRead = true;
    }
    return loadLastRead;
  }
}
