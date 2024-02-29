import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/bookshow_title.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';

class ListMenuTri1 extends StatelessWidget {
  final bool isTablet;
  final bool isDesktop;

  const ListMenuTri1(
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
                text: 'พระวินัยปิฎก',
              ),
            ),
          ),
        ),
        // SubMenuExpansionTile(
        //   titleText: 'พระวินัยปิฎก',
        //   menuList: book_1,
        //   bookAdd: 1,
        //   isTablet: isTablet,
        // ),
        SizedBox(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: book_1.length,
            itemBuilder: (BuildContext innerContext, int innerIndex) {
              return ListTile(
                title: Text(
                  book_1[innerIndex],
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookShowTitle(
                        triBookid: (innerIndex + 1).toString(),
                        chkSearch: '',
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
