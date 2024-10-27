import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/show_title_sub.dart';

class SubMenuNoIconExpansionTile extends StatelessWidget {
  final String titleText;
  final String menuMain;
  final List<List<String>> menuList;
  final bool isTablet;
  final bool isDesktop;
  final bool online;

  const SubMenuNoIconExpansionTile({
    super.key,
    required this.titleText,
    required this.menuMain,
    required this.menuList,
    required this.isTablet,
    required this.isDesktop,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: (!isTablet && !isDesktop)
          ? ATextTitleMedium18(text: titleText)
          : ATextTitleMedium(text: titleText),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(
            menuList.length,
            (index) => ListTile(
              title: (!isTablet && !isDesktop)
                  ? ATextTitleMedium18(text: menuList[index][0])
                  : ATextTitleMedium(text: menuList[index][0]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowTitlePages(
                      wordSearch: menuList[index][0],
                      isM: (!isTablet && !isDesktop) ? true : false,
                      menuList: menuList,
                      menuMain: menuMain,
                      online: online,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
