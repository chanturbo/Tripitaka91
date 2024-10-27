import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/bookshow_title.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';

class ShowBook2 extends StatefulWidget {
  final String txtTitle;
  final bool online;
  const ShowBook2({
    super.key,
    required this.txtTitle,
    required this.online,
  });

  @override
  State<ShowBook2> createState() => _ShowBook2State();
}

class _ShowBook2State extends State<ShowBook2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ATextDiskplayMedium(text: widget.txtTitle),
      ),
      body: Container(
        padding: const EdgeInsets.all(0),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: book_2.length,
          itemBuilder: (BuildContext innerContext, int innerIndex) {
            return ListTile(
              title: Text(
                book_2[innerIndex],
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Roboto', fontSize: 18),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookShowTitle(
                      triBookid: (innerIndex + 11).toString(),
                      chkSearch: '',
                      isMobile: true,
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
