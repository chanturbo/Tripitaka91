import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/features/book/bookshow_title.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';

class ListMenuTri3 extends StatelessWidget {
  final bool isTablet;
  final bool isDesktop;
  final bool online;
  const ListMenuTri3({
    super.key,
    required this.isTablet,
    required this.isDesktop,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ClipPath(
            clipper: RightTriangleRectangleClipper(),
            child: Container(
              height: 25,
              color: TColors.primary1,
              child: const Center(
                child: ATextDiskplayMedium(
                  text: 'พระอภิธรรมปิฎก',
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: book_3.length,
            itemBuilder: (BuildContext innerContext, int innerIndex) {
              return ListTile(
                title: ATextTitleMedium(
                  text: book_3[innerIndex],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookShowTitle(
                        triBookid: (innerIndex + 75).toString(),
                        chkSearch: '',
                        isMobile: false,
                        online: online,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
