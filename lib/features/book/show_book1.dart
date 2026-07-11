import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/features/book/bookshow_title.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';

class ShowBook1 extends StatefulWidget {
  final String txtTitle;
  final bool online;
  const ShowBook1({
    super.key,
    required this.txtTitle,
    required this.online,
  });

  @override
  State<ShowBook1> createState() => _ShowBook1State();
}

class _ShowBook1State extends State<ShowBook1> {
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
          itemCount: book_1.length,
          itemBuilder: (BuildContext innerContext, int innerIndex) {
            return ListTile(
              title: Text(
                book_1[innerIndex],
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Roboto', fontSize: 18),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookShowTitle(
                      triBookid: (innerIndex + 1).toString(),
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
