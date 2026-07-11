import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/features/book/show_title_sub.dart';

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
      title: AResponsiveTitleText(
        text: titleText,
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(
            menuList.length,
            (index) => ListTile(
              title: AResponsiveTitleText(
                text: menuList[index][0],
                isTablet: isTablet,
                isDesktop: isDesktop,
              ),
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
