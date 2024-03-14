import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';
import 'package:tripitaka91/widget/menu/sub_menu_title.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';

class ListMenuTitle extends StatelessWidget {
  final bool isTablet;
  final bool isDesktop;

  const ListMenuTitle(
      {super.key, required this.isTablet, required this.isDesktop});

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
                text: 'หมวดหัวข้อธรรมสำคัญ',
              ),
            ),
          ),
        ),
        SubMenuNoIconExpansionTile(
          titleText: '1.รวมชุดข้อมูลและหัวข้อพระไตรปิฎก',
          menuList: menu_9_1,
          menuMain: "9.1",
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '2.หลักสูตรอินเตอร์เน็ต',
          menuList: menu_9_2,
          menuMain: "9.2",
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '3.แก้ข้อกล่าวหาของสังคมด้วยคำสอนของพระพุทธเจ้า',
          menuList: menu_9_3,
          menuMain: "9.3",
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '4.หัวข้อวัตถุในพระพุทธศาสนาที่ถูกต้อง',
          menuList: menu_9_4,
          menuMain: "9.4",
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '5.หนังสือความประพฤติของพระ',
          menuList: menu_9_5,
          menuMain: "9.5",
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '6.หัวข้อพระวินัยปิฎก และอรรถกถาแปล-พุทธทำนาย',
          menuList: menu_9_6,
          menuMain: "9.6",
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '7.การประกาศ และระเบียบวัด',
          menuList: menu_9_7,
          menuMain: "9.7",
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '8.ข้อมูลประกอบเพิ่มเติม แก้ข้อกล่าวหาสังคม',
          menuList: menu_9_8,
          menuMain: "9.8",
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '9.ข้อมูลพระไตรปิฎก กับเหตุการณ์ปัจจุบัน',
          menuList: menu_9_9,
          menuMain: "9.9",
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
      ],
    );
  }
}
