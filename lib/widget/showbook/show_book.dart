import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/bookshow_title.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';
import 'package:tripitaka91/widget/scroll/scroll_button.dart';
import 'package:tripitaka91/widget/showbook/show_title.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowBookSlide extends StatefulWidget {
  final bool isMobile;
  const ShowBookSlide({super.key, required this.isMobile});

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
                      text: ' หัวข้อธรรมสำคัญ',
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
          height: widget.isMobile ? 180 : 200.0,
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
                                isMobile: widget.isMobile,
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
        ),
        SizedBox(
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
                        uri: _getPdfUri(index),
                        target: LinkTarget.blank,
                        builder: (BuildContext ctx, FollowLink? openLink) {
                          return IconButton(
                            iconSize: 64, // กำหนดขนาดไอคอนตามต้องการ
                            onPressed: openLink,
                            icon: Image.asset(
                              'assets/images/ebook/ebook-${index + 1}.png',
                              fit: BoxFit.cover, // กำหนดการแสดงผลของรูปภาพ
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'APP Tripitaka91 สำหรับ iPhone, iPad',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'สามารถเข้าไปดาวน์โหลดได้แล้ว คลิกที่ลิงก์ด้านล่าง หรือเข้า App Store แล้วพิมพ์คำค้นหา "tripitaka 91"',
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                _buildDownloadButton(
                  platform: 'iTunes App Store',
                  url:
                      'https://apps.apple.com/us/app/tripitaka-91-v3-0/id1087390266',
                  iconPath: 'assets/web/appstore.png',
                ),
                const Divider(height: 30),
                const Text(
                  'APP Tripitaka91 สำหรับเครื่อง Android',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'สามารถเข้าไปดาวน์โหลดได้แล้ว คลิกที่ลิงก์ด้านล่าง หรือเข้า Play Store แล้วพิมพ์คำค้นหา "tripitaka91" และเลือกเวอร์ชั่น 2.1+',
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                _buildDownloadButton(
                  platform: 'Google Play Store',
                  url:
                      'https://play.google.com/store/apps/details?id=com.tripitaka91.tripitaka91&hl=th',
                  iconPath: 'assets/web/playstore.png',
                ),
                const Divider(height: 30),
                // ข้อความสำหรับดาวน์โหลดไฟล์ ePub
                const Text(
                  'ดาวน์โหลดไฟล์ ePub สำหรับเครื่องอ่าน E-book',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'พระไตรปิฎกและอรรถกถาแปล ชุด 91 เล่ม ฉบับมหามกุฏราชวิทยาลัย (เล่มสีน้ำเงิน) พร้อมสารบัญหัวข้อธรรมในแต่ละเล่ม '
                  'ในรูปแบบ E-book สำหรับเครื่องอ่าน Kindle, Sony, Kobo และเครื่องอ่านแท็บเล็ตต่าง ๆ เช่น iPad, iPhone, และ Android',
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                _buildDownloadButton(
                  platform: 'ดาวน์โหลดไฟล์ ePub',
                  url: 'https://www.tripitaka91.com/show_epub_download.php',
                  iconPath:
                      'assets/web/epub.png', // สมมติว่ามีไอคอน ePub ที่ชื่อ epub.png
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 20),
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YouTube',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'วีดีโอจาก YouTube ช่องของวัดสามแยก และช่องอื่น ๆ สำหรับศึกษา',
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                _buildChannelItem(
                  icon: Icons.play_circle_fill,
                  title: 'ช่อง SamyaekMedia',
                  url:
                      'https://www.youtube.com/channel/UC2D_YsjJOr_Iuf3jd9xkZhA', // ใส่ลิงก์ของช่องที่นี่
                ),
                _buildChannelItem(
                  icon: Icons.play_circle_fill,
                  title: 'ช่อง SamyaekTV',
                  url:
                      'https://www.youtube.com/channel/UCQwFnDCExBLIzYAItp8PE8Q',
                ),
                _buildChannelItem(
                  icon: Icons.play_circle_fill,
                  title: 'ช่อง Amarin Karnsri',
                  url:
                      'https://www.youtube.com/channel/UCzlSiuxxnZzSz0uP2nuPq4w',
                ),
                _buildChannelItem(
                  icon: Icons.play_circle_fill,
                  title: 'ช่อง เจษฎา อังศุโชติ',
                  url:
                      'https://www.youtube.com/channel/UC3EF2G7ECDg6Jihf3o_VdkA',
                ),
                _buildChannelItem(
                  icon: Icons.play_circle_fill,
                  title: 'เว็บไซต์ Dhamma Youtube Timstamp (Thailand)',
                  url: 'https://dhamma-youtube-timestamp.blogspot.com/',
                ),
                _buildChannelItem(
                  icon: Icons.headset,
                  title: 'เสียงอ่านพระไตรปิฎก',
                  url:
                      'https://www.youtube.com/user/puttomsong/videos', // ตัวอย่างลิงก์เสียงอ่านพระไตรปิฎก
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 20),
      ],
    );
  }

// ฟังก์ชันสำหรับตรวจสอบและสร้าง URL
  Uri _getPdfUri(int index) {
    const baseUrl =
        'https://www.tripitaka91.com/pdf/showpdf.php?filename=ebook-';
    final suffix = index == 2 ? '-1.pdf' : '.pdf';
    return Uri.parse('$baseUrl${index + 1}$suffix');
  }

  Widget _buildChannelItem(
      {required IconData icon, required String title, required String url}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () async {
          Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $url';
          }
        },
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(
      {required String platform,
      required String url,
      required String iconPath}) {
    return InkWell(
      onTap: () async {
        Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 150, // ขนาดของไอคอน
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              platform,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
