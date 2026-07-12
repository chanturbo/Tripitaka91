import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripitaka91/utils/connectivity/refresh_connectivity.dart';
import 'package:tripitaka91/utils/theme/theme_provider.dart';
import 'package:tripitaka91/widget/appbar/app_bar.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/card/title_card.dart';
import 'package:tripitaka91/widget/home_state_mixin.dart';
import 'package:tripitaka91/widget/last_read/show_last.dart';
import 'package:tripitaka91/widget/last_read/show_last2.dart';
import 'package:tripitaka91/widget/menu/list_menu.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';
import 'package:tripitaka91/widget/search/screen_mobile.dart';
import 'package:tripitaka91/features/book/show_book.dart';

class MyHomeMobile extends StatefulWidget {
  const MyHomeMobile({super.key, required this.title, required this.online});

  final String title;
  final bool online;

  @override
  State<MyHomeMobile> createState() => _MyHomeMobileState();
}

class _MyHomeMobileState extends State<MyHomeMobile>
    with HomeStateMixin<MyHomeMobile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get online => widget.online;
  @override
  bool get isMobileLayout => true;

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListMenu(
          isTablet: false,
          isDesktop: false,
          online: widget.online,
        ),
      ),
      appBar: AppBar(
        title: AppBarCustom(
          isDesktop: false,
          isTablet: false,
          online: widget.online,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white,
            tooltip: 'เข้าสู่ระบบ',
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
          IconButton(
            icon: Icon(widget.online ? Icons.wifi : Icons.wifi_off),
            color: widget.online ? TColors.success : TColors.error,
            tooltip: widget.online ? 'ONLINE' : 'OFFLINE',
            onPressed: () {
              if (widget.online) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('กำลังเชื่อมต่ออินเทอร์เน็ต (ONLINE)'),
                  ),
                );
              } else {
                refreshConnectivityAndRebirthIfOnline(context);
              }
            },
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
                  Container(color: TColors.primary, height: 10),
                  Container(
                    color: TColors.primary,
                    child: SearchMobileScreen(online: widget.online),
                  ),
                  Container(height: 10, color: TColors.primary),
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
                              isMobile: true,
                              online: widget.online,
                            )
                          : DummyLastBookAccessData2(
                              isMobile: true,
                              online: widget.online,
                            ),
                    ],
                  ),
                  Container(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(height: 10),
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
                            online: widget.online,
                          ),
                          Container(height: 20),
                          ShowBookSlide(isMobile: true, online: widget.online),
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
