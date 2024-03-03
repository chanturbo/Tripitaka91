import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/info/info.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';
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
        const ListTile(title: ATextTitleMedium18(text: 'พระวินัยปิฎก')),
        const ListTile(title: ATextTitleMedium18(text: 'พระสุตตันตปิฎก')),
        const ListTile(title: ATextTitleMedium18(text: 'พระอภิธรรมปิฎก')),
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
        const ListTile(
            title:
                ATextTitleMedium18(text: '1.รวมชุดข้อมูลและหัวข้อพระไตรปิฎก')),
        const ListTile(
            title: ATextTitleMedium18(text: '2.หลักสูตรอินเตอร์เน็ต')),
        const ListTile(
            title: ATextTitleMedium18(
          text: '3.แก้ข้อกล่าวหาของสังคมด้วยคำสอนของพระพุทธเจ้า',
        )),
        const ListTile(
            title: ATextTitleMedium18(
          text: '4.หัวข้อวัตถุในพระพุทธศาสนาที่ถูกต้อง',
        )),
        const ListTile(
            title: ATextTitleMedium18(text: '5.หนังสือความประพฤติของพระ')),
        const ListTile(
            title: ATextTitleMedium18(
          text: '6.หัวข้อพระวินัยปิฎก และอรรถกถาแปล-พุทธทำนาย',
        )),
        const ListTile(
            title: ATextTitleMedium18(text: '7.การประกาศ และระเบียบวัด')),
        const ListTile(
            title: ATextTitleMedium18(
          text: '8.ข้อมูลประกอบเพิ่มเติม แก้ข้อกล่าวหาสังคม',
        )),
        const ListTile(
            title: ATextTitleMedium18(
          text: '9.ข้อมูลพระไตรปิฎก กับเหตุการณ์ปัจจุบัน',
        )),
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
