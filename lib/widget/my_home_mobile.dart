import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/appbar/app_bar.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/models/rand_title.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/card/title_card.dart';
import 'package:tripitaka91/widget/last_read/show_last.dart';
import 'package:tripitaka91/widget/last_read/show_last2.dart';
// import 'package:tripitaka91/widget/line_custom/mylinepainter.dart';
import 'package:tripitaka91/widget/menu/list_menu.dart';
import 'package:tripitaka91/widget/pageviews/pageviews_html.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';
import 'package:tripitaka91/widget/search/screen_mobile.dart';
import 'package:tripitaka91/widget/showbook/show_book.dart';

class MyHomeMobile extends StatefulWidget {
  const MyHomeMobile({
    super.key,
    required this.title,
    required this.onToggleGrayscale,
    required this.isGrayscale,
  });

  final String title;
  final VoidCallback onToggleGrayscale;
  final bool isGrayscale;

  @override
  State<MyHomeMobile> createState() => _MyHomeMobileState();
}

class _MyHomeMobileState extends State<MyHomeMobile> {
  var isLoadedTitle = false;
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int sidebarButtonNo = 0;

  late Users? usersList;
  String? book;
  String? page;
  String? line;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    getDataRandTitle();
    userOnline();
    _checkArguments();
    _timer = Timer(const Duration(seconds: 1), _onTimerFinished);
  }

  void _onTimerFinished() {
    if (mounted) {
      // ทำงานก็ต่อเมื่อ widget ยังไม่ถูก dispose

      if ((book != null) && (page != null) && (line != null)) {
        // print('Timer finished book = $book page = $page line = $line');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Tri91PageViewHtml(
              triBookid: book!,
              triPageid: int.parse(page!),
              triBookline: line!,
              chkSearch: '',
              isMobile: true,
            ),
          ),
        );
      }
    }
  }

  void _checkArguments() {
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
    _timer.cancel();
    logOutUser();
    super.dispose();
  }

  Future<void> logOutUser() async {
    clearUsersList();
  }

  Future<void> userOnline() async {
    usersList = await getUsersList();
  }

  Future<void> getDataRandTitle() async {
    try {
      randTitle = await RemoteServiceRandTitle().getRandTitle();
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
      // ignore: avoid_print
      print('Error occurred: $e');
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

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Drawer(
          child: ListMenu(
        isTablet: false,
        isDesktop: false,
      )),
      appBar: AppBar(
        title: const AppBarCustom(
          isDesktop: false,
          isTablet: false,
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isGrayscale ? Icons.visibility_off : Icons.visibility,
            ),
            color: Colors.white, // ใส่สีขาวตรงนี้
            onPressed: widget.onToggleGrayscale,
            tooltip: widget.isGrayscale ? 'ปิดโหมดขาว-ดำ' : 'เปิดโหมดขาว-ดำ',
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(0),
        child: Row(
          children: <Widget>[
            // Container(
            //   alignment: Alignment.topCenter,
            //   child: CustomPaint(
            //     painter: MyVerticalLinePainter(),
            //     size: Size(0.1, screenHeight),
            //   ),
            // ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    color: TColors.primary,
                    height: 10,
                  ),
                  Container(
                      color: TColors.primary,
                      child: const SearchMobileScreen()),
                  Container(
                    height: 10,
                    color: TColors.primary,
                  ),
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: ClipPath(
                          clipper: RightTriangleRectangleClipper(),
                          child: Container(
                            width: 100.0,
                            height: 25.0,
                            color: TColors.primary1,
                            child: const Center(
                              child: ATextDiskplaySmall(
                                text: 'เล่มที่อ่านล่าสุด',
                              ),
                            ),
                          ),
                        ),
                      ),
                      loadLastRead
                          ? const DummyLastBookAccessData(isMobile: true)
                          : const DummyLastBookAccessData2(isMobile: true),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: 10,
                          ),
                          SizedBox(
                            width: 85,
                            height: 30,
                            child: InkWell(
                              onTap: () async {
                                getDataRandTitle();
                              },
                              child: ClipPath(
                                clipper: DoubleTriangleRectangleClipper(),
                                child: Container(
                                  padding: const EdgeInsets.all(0.0),
                                  color: Colors.red, // Change color as needed
                                  child: const Center(
                                    child: ATextDiskplaySmall(
                                      text: 'สุ่มหัวข้อธรรม',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TitleCard(
                            triTitle: triTitle,
                            bookBlue: bookBlue,
                            bookRed: bookRed,
                            bookIds: triBookid,
                            pageId: triPageid,
                            bookLine: triBookline,
                            noTitle: noTitle,
                            noTitleCate: noTitleCate,
                            isMobile: true,
                          ),
                          Container(
                            height: 20,
                          ),
                          const ShowBookSlide(
                            isMobile: true,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _scaffoldKey.currentState?.openDrawer();
      //   },
      //   tooltip: 'เมนู',
      //   child: const Icon(Icons.menu_outlined),
      // ),
    );
  }
}
