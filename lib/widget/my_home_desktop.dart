import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/theme/theme_provider.dart';
import 'package:tripitaka91/widget/appbar/app_bar.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/card/title_card.dart';
import 'package:tripitaka91/widget/home_state_mixin.dart';
import 'package:tripitaka91/widget/last_read/show_last.dart';
import 'package:tripitaka91/widget/last_read/show_last2.dart';
import 'package:tripitaka91/widget/line_custom/mylinepainter.dart';
import 'package:tripitaka91/widget/menu/list_menu.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';
import 'package:tripitaka91/features/book/show_book.dart';

class MyHomeDesktop extends StatefulWidget {
  const MyHomeDesktop({
    super.key,
    required this.title,
    required this.online,
  });

  final String title;
  final bool online;

  @override
  State<MyHomeDesktop> createState() => _MyHomeDesktopState();
}

class _MyHomeDesktopState extends State<MyHomeDesktop>
    with HomeStateMixin<MyHomeDesktop> {
  @override
  bool get online => widget.online;
  @override
  bool get isMobileLayout => false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    //double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: AppBarCustom(
          isDesktop: true,
          isTablet: false,
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
      body: Container(
        padding: const EdgeInsets.all(0),
        child: Row(
          children: [
            Container(
              color: adaptiveSurfaceColor(context),
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              width: 290,
              child: ListMenu(
                isDesktop: true,
                isTablet: false,
                online: widget.online,
              ),
            ),
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
}
