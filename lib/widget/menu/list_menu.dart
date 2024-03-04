import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/info/info.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';
import 'package:tripitaka91/widget/menu/sub_menu_book.dart';
import 'package:tripitaka91/widget/menu/sub_menu_title.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';
import 'package:tripitaka91/widget/showdict/dictshow_dict.dart';
import 'package:tripitaka91/widget/showdict/dictshow_dictbt.dart';

class ListMenu extends StatelessWidget {
  final bool isTablet;
  final bool isDesktop;

  const ListMenu({super.key, required this.isTablet, required this.isDesktop});

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
        SubMenuExpansionTile(
          titleText: 'พระวินัยปิฎก',
          menuList: book_1,
          bookAdd: 1,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuExpansionTile(
          titleText: 'พระสุตตันตปิฎก',
          menuList: book_2,
          bookAdd: 11,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuExpansionTile(
          titleText: 'พระอภิธรรมปิฎก',
          menuList: book_3,
          bookAdd: 75,
          isTablet: isTablet,
          isDesktop: isDesktop,
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
        SubMenuNoIconExpansionTile(
          titleText: '1.รวมชุดข้อมูลและหัวข้อพระไตรปิฎก',
          menuList: menu_9_1,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '2.หลักสูตรอินเตอร์เน็ต',
          menuList: menu_9_2,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '3.แก้ข้อกล่าวหาของสังคมด้วยคำสอนของพระพุทธเจ้า',
          menuList: menu_9_3,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '4.หัวข้อวัตถุในพระพุทธศาสนาที่ถูกต้อง',
          menuList: menu_9_4,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '5.หนังสือความประพฤติของพระ',
          menuList: menu_9_5,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '6.หัวข้อพระวินัยปิฎก และอรรถกถาแปล-พุทธทำนาย',
          menuList: menu_9_6,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '7.การประกาศ และระเบียบวัด',
          menuList: menu_9_7,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '8.ข้อมูลประกอบเพิ่มเติม แก้ข้อกล่าวหาสังคม',
          menuList: menu_9_8,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '9.ข้อมูลพระไตรปิฎก กับเหตุการณ์ปัจจุบัน',
          menuList: menu_9_9,
          isTablet: isTablet,
          isDesktop: isDesktop,
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
          title: (!isTablet && !isDesktop)
              ? const ATextTitleMedium18(text: 'พจนานุกรม ฉบับประมวลศัพท์')
              : const ATextTitleMedium(
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
          title: (!isTablet && !isDesktop)
              ? const ATextTitleMedium18(text: 'พจนานุกรม ไทย-บาลี')
              : const ATextTitleMedium(
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
          title: (!isTablet && !isDesktop)
              ? const ATextTitleMedium18(text: 'เกี่ยวกับโปรแกรม')
              : const Text(
                  'เกี่ยวกับโปรแกรม',
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
