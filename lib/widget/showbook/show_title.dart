import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/show_title_sub.dart';

class SubShowTitle extends StatefulWidget {
  final String titleText;
  final String menuMain;
  final List<List<String>> menuList;
  final bool isMobile;

  const SubShowTitle(
      {super.key,
      required this.titleText,
      required this.menuList,
      required this.menuMain,
      required this.isMobile});

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
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(5),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.menuList.length,
          itemBuilder: (BuildContext innerContext, int innerIndex) {
            return ListTile(
              title: ATextTitleMedium18(text: widget.menuList[innerIndex][0]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowTitlePages(
                      wordSearch: widget.menuList[innerIndex][0],
                      isM: false,
                      menuList: widget.menuList,
                      menuMain: widget.menuMain,
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
