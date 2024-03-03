import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/info/info.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';
import 'package:tripitaka91/widget/showbook/show_book1.dart';
import 'package:tripitaka91/widget/showbook/show_book2.dart';
import 'package:tripitaka91/widget/showbook/show_book3.dart';
import 'package:tripitaka91/widget/showbook/show_title.dart';
import 'package:tripitaka91/widget/showdict/dictshow_dict.dart';
import 'package:tripitaka91/widget/showdict/dictshow_dictbt.dart';

class ListMenuMobile extends StatelessWidget {
  const ListMenuMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          height: 10,
        ),
        ClipPath(
          clipper: RightTriangleRectangleClipper(),
          child: Container(
            width: 100,
            height: 25,
            color: TColors.primary,
            child: const Center(
              child: ATextDiskplayMedium(
                text: 'หมวดพระไตรปิฎก',
              ),
            ),
          ),
        ),
        ListTile(
          title: const ATextTitleMedium18(text: 'พระวินัยปิฎก'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShowBook1(
                  txtTitle: 'พระวินัยปิฎก',
                ),
              ),
            );
          },
        ),
        ListTile(
          title: const ATextTitleMedium18(text: 'พระสุตตันตปิฎก'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShowBook2(
                  txtTitle: 'พระสุตตันตปิฎก',
                ),
              ),
            );
          },
        ),
        ListTile(
          title: const ATextTitleMedium18(text: 'พระอภิธรรมปิฎก'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShowBook3(
                  txtTitle: 'พระอภิธรรมปิฎก',
                ),
              ),
            );
          },
        ),
        ClipPath(
          clipper: RightTriangleRectangleClipper(),
          child: Container(
            width: 100,
            height: 25,
            color: TColors.primary,
            child: const Center(
              child: ATextDiskplayMedium(
                text: 'หมวดหัวข้อธรรมสำคัญ',
              ),
            ),
          ),
        ),
        ListTile(
          title: const ATextTitleMedium18(
              text: '1.รวมชุดข้อมูลและหัวข้อพระไตรปิฎก'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubShowTitle(
                    titleText: '1.รวมชุดข้อมูลและหัวข้อพระไตรปิฎก',
                    menuList: menu_9_1),
              ),
            );
          },
        ),
        ListTile(
          title: const ATextTitleMedium18(text: '2.หลักสูตรอินเตอร์เน็ต'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubShowTitle(
                    titleText: '2.หลักสูตรอินเตอร์เน็ต', menuList: menu_9_2),
              ),
            );
          },
        ),
        ListTile(
          title: const ATextTitleMedium18(
            text: '3.แก้ข้อกล่าวหาของสังคมด้วยคำสอนของพระพุทธเจ้า',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubShowTitle(
                    titleText: '3.แก้ข้อกล่าวหาของสังคมด้วยคำสอนของพระพุทธเจ้า',
                    menuList: menu_9_3),
              ),
            );
          },
        ),
        ListTile(
          title: const ATextTitleMedium18(
            text: '4.หัวข้อวัตถุในพระพุทธศาสนาที่ถูกต้อง',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubShowTitle(
                    titleText: '4.หัวข้อวัตถุในพระพุทธศาสนาที่ถูกต้อง',
                    menuList: menu_9_4),
              ),
            );
          },
        ),
        ListTile(
          title: const ATextTitleMedium18(text: '5.หนังสือความประพฤติของพระ'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubShowTitle(
                    titleText: '5.หนังสือความประพฤติของพระ',
                    menuList: menu_9_5),
              ),
            );
          },
        ),
        ListTile(
          title: const ATextTitleMedium18(
            text: '6.หัวข้อพระวินัยปิฎก และอรรถกถาแปล-พุทธทำนาย',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubShowTitle(
                    titleText: '6.หัวข้อพระวินัยปิฎก และอรรถกถาแปล-พุทธทำนาย',
                    menuList: menu_9_6),
              ),
            );
          },
        ),
        ListTile(
          title: const ATextTitleMedium18(text: '7.การประกาศ และระเบียบวัด'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubShowTitle(
                    titleText: '7.การประกาศ และระเบียบวัด', menuList: menu_9_7),
              ),
            );
          },
        ),
        ListTile(
          title: const ATextTitleMedium18(
            text: '8.ข้อมูลประกอบเพิ่มเติม แก้ข้อกล่าวหาสังคม',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubShowTitle(
                    titleText: '8.ข้อมูลประกอบเพิ่มเติม แก้ข้อกล่าวหาสังคม',
                    menuList: menu_9_8),
              ),
            );
          },
        ),
        ListTile(
          title: const ATextTitleMedium18(
            text: '9.ข้อมูลพระไตรปิฎก กับเหตุการณ์ปัจจุบัน',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubShowTitle(
                    titleText: '9.ข้อมูลพระไตรปิฎก กับเหตุการณ์ปัจจุบัน',
                    menuList: menu_9_9),
              ),
            );
          },
        ),
        ClipPath(
          clipper: RightTriangleRectangleClipper(),
          child: Container(
            width: 100,
            height: 25,
            color: TColors.primary,
            child: const Center(
              child: ATextDiskplayMedium(
                text: 'พจนานุกรม',
              ),
            ),
          ),
        ),
        ListTile(
          title: const ATextTitleMedium18(
            text: 'พจนานุกรม ฉบับประมวลศัพท์',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DictShowTitle(),
              ),
            );
          },
        ),
        ListTile(
          title: const ATextTitleMedium18(
            text: 'พจนานุกรม ไทย-บาลี',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DictbtShowTitle(),
              ),
            );
          },
        ),
        ClipPath(
          clipper: RightTriangleRectangleClipper(),
          child: Container(
            width: 100,
            height: 25,
            color: TColors.primary,
            child: const Center(
              child: ATextDiskplayMedium(
                text: 'เกี่ยวกับโปรแกรม',
              ),
            ),
          ),
        ),
        ListTile(
          title: const ATextTitleMedium18(
            text: 'เกี่ยวกับโปรแกรม',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TripitakaInfoWidget(),
              ),
            );
          },
        ),
      ],
    );
  }
}
