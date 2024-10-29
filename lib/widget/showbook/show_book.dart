import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/bookshow_title.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';
import 'package:tripitaka91/widget/scroll/scroll_button.dart';
import 'package:tripitaka91/widget/showbook/show_title.dart';
import 'package:url_launcher/link.dart';

class ShowBookSlide extends StatefulWidget {
  final bool isMobile;
  final bool online;
  const ShowBookSlide({
    super.key,
    required this.isMobile,
    required this.online,
  });

  @override
  State<ShowBookSlide> createState() => _ShowBookSlideState();
}

class _ShowBookSlideState extends State<ShowBookSlide> {
  final ScrollController _scrollControllerListView = ScrollController();
  final ScrollController _scrollControllerListView2 = ScrollController();
  final ScrollController _scrollControllerListView3 = ScrollController();
  final ScrollController _scrollControllerListView4 = ScrollController();
  final ScrollController _scrollControllerListView5 = ScrollController();

  final List<Map<String, dynamic>> dataList = [
    {
      'titleText': '1.รวมชุดข้อมูลและหัวข้อพระไตรปิฎก',
      'menuList': menu_9_1,
      'menuMain': "9.1",
    },
    {
      'titleText': '2.หลักสูตรอินเตอร์เน็ต',
      'menuList': menu_9_2,
      'menuMain': "9.2",
    },
    {
      'titleText': '3.แก้ข้อกล่าวหาของสังคมด้วยคำสอนของพระพุทธเจ้า',
      'menuList': menu_9_3,
      'menuMain': '9.3',
    },
    {
      'titleText': '4.หัวข้อวัตถุในพระพุทธศาสนาที่ถูกต้อง',
      'menuList': menu_9_4,
      'menuMain': "9.4",
    },
    {
      'titleText': '5.หนังสือความประพฤติของพระ',
      'menuList': menu_9_5,
      'menuMain': "9.5",
    },
    {
      'titleText': '6.หัวข้อพระวินัยปิฎก และอรรถกถาแปล-พุทธทำนาย',
      'menuList': menu_9_6,
      'menuMain': "9.6",
    },
    {
      'titleText': '7.การประกาศ และระเบียบวัด',
      'menuList': menu_9_7,
      'menuMain': "9.7",
    },
    {
      'titleText': '8.ข้อมูลประกอบเพิ่มเติม แก้ข้อกล่าวหาสังคม',
      'menuList': menu_9_8,
      'menuMain': "9.8",
    },
    {
      'titleText': '9.ข้อมูลพระไตรปิฎก กับเหตุการณ์ปัจจุบัน',
      'menuList': menu_9_9,
      'menuMain': "9.9",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: ClipPath(
                clipper: RightTriangleRectangleClipper(),
                child: Container(
                  width: 100.0,
                  height: 25.0,
                  color: TColors.secondary,
                  child: const Center(
                    child: ATextDiskplaySmall(
                      text: 'พระวินัยปิฎก',
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(
              child: SizedBox(width: 16.0),
            ),
            ScrollControlButton(
              scrollController: _scrollControllerListView,
              offset: 150,
              buttonText: '<-เลื่อน',
              isLeftButton: true,
              color: TColors.secondary,
            ),
            ScrollControlButton(
              scrollController: _scrollControllerListView,
              offset: 150,
              buttonText: 'เลื่อน->',
              isLeftButton: false,
              color: TColors.secondary,
            ),
          ],
        ),
        SizedBox(
          height: widget.isMobile ? 180 : 200.0,
          child: ListView.builder(
            controller: _scrollControllerListView,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // ปรับแต่งตามความต้องการ
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookShowTitle(
                                triBookid: (index + 1).toString(),
                                chkSearch: "",
                                isMobile: widget.isMobile,
                                online: widget.online,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10), // ปรับแต่งตามความต้องการ
                          child: Image(
                            image: AssetImage(
                                'assets/images/bookcover/tripitaka91_book${index + 1}.png'),
                            fit: BoxFit.cover, // ปรับตามความต้องการ
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
                  color: TColors.secondary,
                  child: const Center(
                    child: ATextDiskplaySmall(
                      text: 'พระสุตตันตปิฎก',
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(
              child: SizedBox(width: 16.0),
            ),
            ScrollControlButton(
              scrollController: _scrollControllerListView2,
              offset: 150,
              buttonText: '<-เลื่อน',
              isLeftButton: true,
              color: TColors.secondary,
            ),
            ScrollControlButton(
              scrollController: _scrollControllerListView2,
              offset: 150,
              buttonText: 'เลื่อน->',
              isLeftButton: false,
              color: TColors.secondary,
            ),
          ],
        ),
        SizedBox(
          height: widget.isMobile ? 180 : 200.0,
          child: ListView.builder(
            controller: _scrollControllerListView2,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: 64,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // ปรับแต่งตามความต้องการ
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookShowTitle(
                                triBookid: (index + 11).toString(),
                                chkSearch: "",
                                isMobile: widget.isMobile,
                                online: widget.online,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10), // ปรับแต่งตามความต้องการ
                          child: Image(
                            image: AssetImage(
                                'assets/images/bookcover/tripitaka91_book${index + 11}.png'),
                            fit: BoxFit.cover, // ปรับตามความต้องการ
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
                  color: TColors.secondary,
                  child: const Center(
                    child: ATextDiskplaySmall(
                      text: 'พระอภิธรรมปิฎก',
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(
              child: SizedBox(width: 16.0),
            ),
            ScrollControlButton(
              scrollController: _scrollControllerListView3,
              offset: 150,
              buttonText: '<-เลื่อน',
              isLeftButton: true,
              color: TColors.secondary,
            ),
            ScrollControlButton(
              scrollController: _scrollControllerListView3,
              offset: 150,
              buttonText: 'เลื่อน->',
              isLeftButton: false,
              color: TColors.secondary,
            ),
          ],
        ),
        SizedBox(
          height: widget.isMobile ? 180 : 200.0,
          child: ListView.builder(
            controller: _scrollControllerListView3,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: 17,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // ปรับแต่งตามความต้องการ
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookShowTitle(
                                triBookid: (index + 75).toString(),
                                chkSearch: "",
                                isMobile: widget.isMobile,
                                online: widget.online,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10), // ปรับแต่งตามความต้องการ
                          child: Image(
                            image: AssetImage(
                                'assets/images/bookcover/tripitaka91_book${index + 75}.png'),
                            fit: BoxFit.cover, // ปรับตามความต้องการ
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
                  color: TColors.primary,
                  child: const Center(
                    child: ATextDiskplaySmall(
                      text: 'หัวข้อธรรมสำคัญ',
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(
              child: SizedBox(width: 16.0),
            ),
            ScrollControlButton(
              scrollController: _scrollControllerListView5,
              offset: 150,
              buttonText: '<-เลื่อน',
              isLeftButton: true,
              color: TColors.primary,
            ),
            ScrollControlButton(
              scrollController: _scrollControllerListView5,
              offset: 150,
              buttonText: 'เลื่อน->',
              isLeftButton: false,
              color: TColors.primary,
            ),
          ],
        ),
        SizedBox(
          height: widget.isMobile ? 200 : 230.0,
          child: ListView.builder(
            controller: _scrollControllerListView5,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: dataList.length,
            itemBuilder: (BuildContext context, int index) {
              final item = dataList[index];
              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // ปรับแต่งตามความต้องการ
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubShowTitle(
                                titleText: item['titleText'],
                                menuList: item['menuList'],
                                menuMain: item['menuMain'],
                                online: widget.online,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10), // ปรับแต่งตามความต้องการ
                          child: Image(
                            image: AssetImage(
                                'assets/images/title/title_0${index + 1}.png'),
                            fit: BoxFit.cover, // ปรับตามความต้องการ
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          height: 10,
        ),
        widget.online
            ? Row(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: ClipPath(
                      clipper: RightTriangleRectangleClipper(),
                      child: Container(
                        width: 100.0,
                        height: 25.0,
                        color: TColors.primary,
                        child: const Center(
                          child: ATextDiskplaySmall(
                            text: 'หนังสือแนะนำ',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(width: 16.0),
                  ),
                  ScrollControlButton(
                    scrollController: _scrollControllerListView4,
                    offset: 150,
                    buttonText: '<-เลื่อน',
                    isLeftButton: true,
                    color: TColors.primary,
                  ),
                  ScrollControlButton(
                    scrollController: _scrollControllerListView4,
                    offset: 150,
                    buttonText: 'เลื่อน->',
                    isLeftButton: false,
                    color: TColors.primary,
                  ),
                ],
              )
            : const SizedBox.shrink(),
        widget.online
            ? SizedBox(
                height: widget.isMobile ? 200 : 230.0,
                child: ListView.builder(
                  controller: _scrollControllerListView4,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: 6,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // ปรับแต่งตามความต้องการ
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Link(
                              uri: index == 2
                                  ? Uri.parse(
                                      'https://www.tripitaka91.com/pdf/showpdf.php?filename=ebook-${index + 1}-1.pdf')
                                  : Uri.parse(
                                      'https://www.tripitaka91.com/pdf/showpdf.php?filename=ebook-${index + 1}.pdf'),
                              target: LinkTarget.blank,
                              builder:
                                  (BuildContext ctx, FollowLink? openLink) {
                                return IconButton(
                                  onPressed: openLink,
                                  icon: Image.asset(
                                      'assets/images/ebook/ebook-${index + 1}.png'), // เปลี่ยนเป็นที่อยู่ของรูปภาพที่คุณต้องการแสดง
                                );
                              },
                            ),
                            // child: InkWell(
                            //   onTap: () {},
                            //   child: ClipRRect(
                            //     borderRadius: BorderRadius.circular(
                            //         10), // ปรับแต่งตามความต้องการ
                            //     child: Image(
                            //       image: AssetImage(
                            //           'assets/images/ebook/ebook-${index + 1}.png'),
                            //       fit: BoxFit.cover, // ปรับตามความต้องการ
                            //     ),
                            //   ),
                            // ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
