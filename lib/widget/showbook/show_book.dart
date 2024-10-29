import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/bookshow_title.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';
import 'package:tripitaka91/widget/scroll/scroll_button.dart';
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
