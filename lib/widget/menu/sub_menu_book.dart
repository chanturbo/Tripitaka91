import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/bookshow_title.dart';

class SubMenuExpansionTile extends StatelessWidget {
  final String titleText;
  final List<String> menuList;
  final int bookAdd;
  final bool isTablet;
  final bool isDesktop;

  const SubMenuExpansionTile({
    super.key,
    required this.titleText,
    required this.menuList,
    required this.bookAdd,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: isTablet
          ? null
          : const Icon(
              Icons.book_outlined,
              color: TColors.primary,
            ),
      title: (!isTablet && !isDesktop)
          ? ATextTitleMedium18(text: titleText)
          : ATextBodyMedium(
              text: titleText,
            ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: menuList.map((item) {
            int index = menuList.indexOf(item);
            return ListTile(
              title: (!isTablet && !isDesktop)
                  ? ATextTitleMedium18(text: item)
                  : ATextTitleMedium(text: item),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookShowTitle(
                      triBookid: (index + bookAdd).toString(),
                      chkSearch: '',
                      isMobile: (!isTablet && !isDesktop) ? true : isTablet,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
