import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/theme/theme_provider.dart';
import 'package:tripitaka91/widget/appbar/app_bar.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/card/title_card.dart';
import 'package:tripitaka91/widget/home_state_mixin.dart';
import 'package:tripitaka91/widget/info/info.dart';
import 'package:tripitaka91/widget/last_read/show_last.dart';
import 'package:tripitaka91/widget/last_read/show_last2.dart';
import 'package:tripitaka91/widget/line_custom/mylinepainter.dart';
import 'package:tripitaka91/widget/menu/list_menu.dart';
import 'package:tripitaka91/widget/menu/list_menu_dict.dart';
import 'package:tripitaka91/widget/menu/list_menu_title.dart';
import 'package:tripitaka91/widget/menu/list_menu_tri11_74.dart';
import 'package:tripitaka91/widget/menu/list_menu_tri1_10.dart';
import 'package:tripitaka91/widget/menu/list_menu_tri75_91.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';
import 'package:tripitaka91/features/book/show_book.dart';

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

class _MyHomeTabletState extends State<MyHomeTablet>
    with HomeStateMixin<MyHomeTablet> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int sidebarButtonNo = 0;

  @override
  bool get online => widget.online;
  @override
  bool get isMobileLayout => false;

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
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white,
            onPressed: checkLoginStatus,
          ),
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
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            color: Colors.white,
            tooltip: context.watch<ThemeProvider>().isDarkMode
                ? 'ปิดโหมดกลางคืน'
                : 'เปิดโหมดกลางคืน',
            onPressed: () {
              context.read<ThemeProvider>().toggleDarkMode();
            },
          ),
        ],
      ),
      drawer: Container(
        color: adaptiveSurfaceColor(context),
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

  Widget sideBar() {
    return Container(
      width: 125,
      height: MediaQuery.of(context).size.height,
      color: adaptiveSurfaceColor(context),
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

  Widget sideBarItem(
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
