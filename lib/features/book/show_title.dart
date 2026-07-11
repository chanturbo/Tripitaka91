import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/features/book/show_title_sub.dart';

class SubShowTitle extends StatefulWidget {
  final String titleText;
  final String menuMain;
  final List<List<String>> menuList;
  final bool online;

  const SubShowTitle({
    super.key,
    required this.titleText,
    required this.menuList,
    required this.menuMain,
    required this.online,
  });

  @override
  State<SubShowTitle> createState() => _SubShowTitleState();
}

class _SubShowTitleState extends State<SubShowTitle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ATextDiskplayMedium(text: widget.titleText),
      ),
      body: Container(
        padding: const EdgeInsets.all(0),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.menuList.length,
          itemBuilder: (BuildContext innerContext, int innerIndex) {
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tileColor: adaptiveSurfaceColor(innerContext), // สีพื้นหลัง
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(Icons.menu_book,
                  color: Colors.blueAccent, size: 28), // ไอคอนนำหน้า
              title: ATextTitleMedium18(text: widget.menuList[innerIndex][0]),
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: Colors.grey, size: 18), // ไอคอนลูกศรขวา
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowTitlePages(
                      wordSearch: widget.menuList[innerIndex][0],
                      isM: true,
                      menuList: widget.menuList,
                      menuMain: widget.menuMain,
                      online: widget.online,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
