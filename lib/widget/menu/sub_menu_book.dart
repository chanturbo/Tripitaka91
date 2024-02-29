import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/bookshow_title.dart';

class SubMenuExpansionTile extends StatefulWidget {
  final String titleText;
  final List<String> menuList;
  final int bookAdd;
  final bool isTablet;

  const SubMenuExpansionTile(
      {super.key,
      required this.titleText,
      required this.menuList,
      required this.bookAdd,
      required this.isTablet});

  @override
  State<SubMenuExpansionTile> createState() => _SubMenuExpansionTileState();
}

class _SubMenuExpansionTileState extends State<SubMenuExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: widget.isTablet
          ? null
          : const Icon(
              Icons.book_outlined,
              color: TColors.primary,
            ),
      title: ATextBodyMedium(
        text: widget.titleText,
      ),
      children: [
        SizedBox(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.menuList.length,
            itemBuilder: (BuildContext innerContext, int innerIndex) {
              return ListTile(
                title: Text(
                  widget.menuList[innerIndex],
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookShowTitle(
                        triBookid: (innerIndex + widget.bookAdd).toString(),
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
