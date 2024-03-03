import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/bookshow_title.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';

class ListMenuTri2 extends StatelessWidget {
  final bool isTablet;
  final bool isDesktop;

  const ListMenuTri2(
      {super.key, required this.isTablet, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ClipPath(
            clipper: RightTriangleRectangleClipper(),
            child: Container(
              width: 100,
              height: 25,
              color: TColors.primary,
              child: const Center(
                child: ATextDiskplayMedium(
                  text: 'พระสุตตันตปิฎก',
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: book_2.length,
            itemBuilder: (BuildContext innerContext, int innerIndex) {
              return ListTile(
                title: Text(
                  book_2[innerIndex],
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookShowTitle(
                        triBookid: (innerIndex + 11).toString(),
                        chkSearch: '',
                        isMobile: false,
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
