import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';
import 'package:tripitaka91/widget/showdict/dictshow_dict.dart';
import 'package:tripitaka91/widget/showdict/dictshow_dictbt.dart';

class ListMenuDict extends StatelessWidget {
  final bool isTablet;
  final bool isDesktop;

  const ListMenuDict(
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
                text: 'พจนานุกรม',
              ),
            ),
          ),
        ),
        ListTile(
          title: const Text(
            'พจนานุกรม ฉบับประมวลศัพท์',
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
          title: const Text(
            'พจนานุกรม ไทย-บาลี',
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
      ],
    );
  }
}
