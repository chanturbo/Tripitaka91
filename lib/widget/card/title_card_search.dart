import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/pageviews/pageviews.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';

class TitleCardSearch extends StatefulWidget {
  final int indexNo;
  final String triTitle;
  final String bookBlue;
  final String bookRed;
  final String bookIds;
  final String bookLine;
  final int pageId;
  final String wordsearch;

  const TitleCardSearch(
      {super.key,
      required this.indexNo,
      required this.triTitle,
      required this.bookBlue,
      required this.bookRed,
      required this.bookLine,
      required this.bookIds,
      required this.pageId,
      required this.wordsearch});

  @override
  State<TitleCardSearch> createState() => _TitleCardSearchState();
}

class _TitleCardSearchState extends State<TitleCardSearch> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(1.0),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: ATextBodyMedium(text: widget.indexNo.toString()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Tri91PageView(
                        triBookid: widget.bookIds,
                        triPageid: widget.pageId,
                        triBookline: widget.bookLine,
                        chkSearch: widget.wordsearch),
                  ),
                );
              },
              title: ATextBodyMedium(
                text: widget.triTitle,
              ),
            ),
            Container(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(width: 45),
                Icon(
                  Icons.volume_up,
                  color: Colors.blue[300], // Change color as needed
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.share,
                  color: Colors.blue[300], // Change color as needed
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.copy,
                  color: Colors.blue[300], // Change color as needed
                ),
                const SizedBox(width: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ClipPath(
                    clipper: DoubleTriangleRectangleClipper(),
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      color: Colors.blue, // Change color as needed
                      child: Center(
                        child: ATextDiskplaySmall(
                          text: 'เล่มสีน้ำเงิน ${widget.bookBlue}',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ClipPath(
                    clipper: DoubleTriangleRectangleClipper(),
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      color: Colors.red, // Change color as needed
                      child: Center(
                        child: ATextDiskplaySmall(
                          text:
                              'เล่มสีแดง ${widget.bookRed}', // Access widget property
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
