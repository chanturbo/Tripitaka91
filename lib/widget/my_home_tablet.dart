import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/auth/authentication_service.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/db_helper/db_helper.dart';
import 'package:tripitaka91/utils/models/rand_title.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/theme/theme_provider.dart';
import 'package:tripitaka91/widget/appbar/app_bar.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/card/title_card.dart';
import 'package:tripitaka91/widget/info/info.dart';
import 'package:tripitaka91/widget/last_read/show_last.dart';
import 'package:tripitaka91/widget/last_read/show_last2.dart';
import 'package:tripitaka91/widget/line_custom/mylinepainter.dart';
import 'package:tripitaka91/widget/login/login.dart';
import 'package:tripitaka91/widget/login/member_tab_show.dart';
import 'package:tripitaka91/widget/menu/list_menu.dart';
import 'package:tripitaka91/widget/menu/list_menu_dict.dart';
import 'package:tripitaka91/widget/menu/list_menu_title.dart';
import 'package:tripitaka91/widget/menu/list_menu_tri11_74.dart';
import 'package:tripitaka91/widget/menu/list_menu_tri1_10.dart';
import 'package:tripitaka91/widget/menu/list_menu_tri75_91.dart';
import 'package:tripitaka91/widget/pageviews/pageviews_html.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';
import 'package:tripitaka91/widget/showbook/show_book.dart';

class MyHomeTablet extends StatefulWidget {
  const MyHomeTablet({
    super.key,
    required this.title,
    required this.online,
  });

  final String title;
  final bool online;

  @override
  State<MyHomeTablet> createState() => _MyHomeTabletState();
}

class _MyHomeTabletState extends State<MyHomeTablet> {
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

  final dbHelper = DatabaseHelper();

  final AuthenticationService _authService = AuthenticationService();
  bool isLoggedIn = false;

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
              isMobile: false,
              online: widget.online,
            ),
          ),
        );
      }
    }
  }

  // Future<void> _checkLoginStatus() async {
  //   isLoggedIn = await _authService.checkLoginStatus();
  //   if (!mounted) return;
  //   if (isLoggedIn) {
  //     // ignore: use_build_context_synchronously
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => const MemberTabShow(indexShow: 0)),
  //     );
  //   } else {
  //     // ignore: use_build_context_synchronously
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const LoginPage(),
  //       ),
  //     );
  //   }
  // }

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
    // clearUsersList();
  }

  Future<void> userOnline() async {
    usersList = await getUsersList();
  }

  Future<void> getDataRandTitle() async {
    try {
      widget.online
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
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: AppBarCustom(
          isDesktop: false,
          isTablet: true,
          online: widget.online,
        ),
        actions: [
          /*IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white,
            onPressed: _checkLoginStatus,
          ),*/
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isGrayscale
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            color: Colors.white,
            tooltip: context.watch<ThemeProvider>().isGrayscale
                ? 'ปิดโหมดขาว-ดำ'
                : 'เปิดโหมดขาว-ดำ',
            onPressed: () {
              context.read<ThemeProvider>().toggleGrayscale();
            },
          ),
        ],
      ),
      drawer: Container(
        color: TColors.white,
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        width: 290,
        child: sidebarButtonNo == 1
            ? ListMenuTri1(
                isDesktop: true,
                isTablet: false,
                online: widget.online,
              )
            : sidebarButtonNo == 2
                ? ListMenuTri2(
                    isDesktop: true,
                    isTablet: false,
                    online: widget.online,
                  )
                : sidebarButtonNo == 3
                    ? ListMenuTri3(
                        isDesktop: true,
                        isTablet: false,
                        online: widget.online,
                      )
                    : sidebarButtonNo == 4
                        ? ListMenuTitle(
                            isDesktop: true,
                            isTablet: false,
                            online: widget.online,
                          )
                        : sidebarButtonNo == 5
                            ? ListMenuDict(
                                isDesktop: true,
                                isTablet: false,
                                online: widget.online,
                              )
                            : ListMenu(
                                isDesktop: true,
                                isTablet: false,
                                online: widget.online,
                              ),
      ),
      body: Container(
        padding: const EdgeInsets.all(0),
        child: Row(
          children: [
            sideBar(),
            Container(
              alignment: Alignment.topCenter,
              child: CustomPaint(
                painter: MyVerticalLinePainter(),
                size: Size(0.5, screenHeight),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 10,
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
                          ? DummyLastBookAccessData(
                              isMobile: false,
                              online: widget.online,
                            )
                          : DummyLastBookAccessData2(
                              isMobile: false,
                              online: widget.online,
                            ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
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
                            isMobile: false,
                            online: widget.online,
                          ),
                          Container(
                            height: 20,
                          ),
                          ShowBookSlide(
                            isMobile: false,
                            online: widget.online,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  sideBar() {
    return Container(
      width: 125,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          Container(),
          sideBarItem(Icons.home, 'หน้าแรก', true, 0, Colors.blue),
          const Divider(height: 5),
          sideBarItem(
              Icons.book_outlined, 'พระวินัยปิฎก', true, 1, Colors.blue),
          sideBarItem(
              Icons.book_outlined, 'พระสุตตันตปิฎก', true, 2, Colors.blue),
          sideBarItem(
              Icons.book_outlined, 'พระอภิธรรมปิฎก', true, 3, Colors.blue),
          const Divider(height: 5),
          sideBarItem(Icons.book, 'หัวข้อธรรมสำคัญ', true, 4, Colors.blue),
          const Divider(height: 5),
          sideBarItem(Icons.book, 'พจนานุกรม', true, 5, Colors.blue),
          const Divider(height: 5),
          sideBarItem(
              Icons.account_balance, 'เกี่ยวกับโปรแกรม', true, 6, Colors.blue),
          const Divider(height: 5),
        ],
      ),
    );
  }

  sideBarItem(
      IconData iconData, String text, bool isprimary, int index, Color bColor) {
    return MaterialButton(
        color: index == sidebarButtonNo ? Colors.grey[200] : Colors.transparent,
        height: 80,
        highlightElevation: 0,
        elevation: 0,
        hoverElevation: 0,
        onPressed: () {
          setState(() {
            sidebarButtonNo = index;
            if (sidebarButtonNo == 6) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TripitakaInfoWidget(),
                ),
              );
            } else {
              _scaffoldKey.currentState?.openDrawer();
            }
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              //color: Color(0XFF18bc9c),
              //backgroundColor: Color(0XFFf5b931),
              backgroundColor: index == sidebarButtonNo
                  ? Colors.white
                  : const Color(0XFFf5b931), //Colors.grey[300],
              child: Icon(iconData,
                  color: index == sidebarButtonNo ? Colors.red : Colors.white,
                  size: 25),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ATextBodySmall(text: text),
              ],
            )
          ],
        ));
  }
}
