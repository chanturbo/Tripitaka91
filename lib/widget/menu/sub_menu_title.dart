import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/bookshow/show_title_sub.dart';

class SubMenuNoIconExpansionTile extends StatefulWidget {
  final String titleText;
  final List<String> menuList;

  const SubMenuNoIconExpansionTile(
      {super.key, required this.titleText, required this.menuList});

  @override
  State<SubMenuNoIconExpansionTile> createState() =>
      _SubMenuNoIconExpansionTileState();
}

class _SubMenuNoIconExpansionTileState
    extends State<SubMenuNoIconExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        widget.titleText,
      ),
      children: [
        SizedBox(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.menuList.length,
            itemBuilder: (BuildContext innerContext, int innerIndex) {
              return ListTile(
                title: Text(widget.menuList[innerIndex]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowTitlePages(
                        wordSearch: widget.menuList[innerIndex],
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
