import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/last_book_access.dart';
import 'package:tripitaka91/utils/models/rand_title.dart';
import 'package:tripitaka91/utils/models/tri91_bookall.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/show_title_list.dart';
import 'package:tripitaka91/widget/pageviews/pageviews.dart';

class BookShowTitle extends StatefulWidget {
  final String triBookid;
  final String chkSearch;
  final bool isMobile;
  const BookShowTitle({
    super.key,
    required this.triBookid,
    required this.chkSearch,
    required this.isMobile,
  });

  @override
  State<BookShowTitle> createState() => _BookShowTitleState();
}

class _BookShowTitleState extends State<BookShowTitle> {
  late List<RandTitle> randTitle = [];
  late List<Tri91BookAll> tri91BookAll = [];
  late List<LastBookAccess> lastBookAccess = [];
  late String bookTitleTri91 = 'โหลดข้อมูล...';
  late int numPageAll = 0;
  late String triCatage = 'โหลดข้อมูล...';
  late int bookReadall = 0;
  late String bookLastAccess = 'โหลดข้อมูล...';
  late int bookLastPages = 0;
  late int bookLastLine = 0;
  late String bookid = widget.triBookid;
  Users? users;

  @override
  void initState() {
    super.initState();
    _getUser();
    _getLastBook();
    getDataTri91();
  }

  Future<void> _getUser() async {
    users = await getUsersList();
  }

  Future<void> _getLastBook() async {
    GetLastRead getLastRead = GetLastRead();
    List<LastBookAccess> result = await getLastRead.fetchLastBookAccessList();
    int targetBookAccess =
        int.parse(widget.triBookid); // เปลี่ยนตามที่คุณต้องการ
    List<LastBookAccess> filteredResult = result
        .where((lastBookAccess) =>
            lastBookAccess.bookLastAccess == targetBookAccess)
        .toList();

    lastBookAccess = filteredResult;
    // print(lastBookAccess[0].bookLastAccess);
    // print(lastBookAccess[0].pageLastAccess);
    // print(lastBookAccess[0].timeLastAccess);
    // print(lastBookAccess[0].username);
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    if (users != null) {
    } else {
      String mgr = 'กรุณาเข้าสู่ระบบก่อน';
      showCustomDialog(context, mgr);
    }
  }

  void showCustomDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // สร้าง AlertDialog
        return AlertDialog(
          title: const Text('รายงาน'),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                // ปิด Dialog
                Navigator.of(context).pop();
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Future<List<RandTitle?>> fetchDataTitle() async {
    randTitle =
        (await RemoteServiceTitle().getTitle(widget.triBookid, tSecretAPIKey))!;

    return randTitle;
  }

  void getDataTri91() async {
    try {
      tri91BookAll = await RemoteServiceBookTri91All()
              .getBookTri91All(widget.triBookid, tSecretAPIKey) ??
          [];
      if (tri91BookAll.isNotEmpty) {
        setState(() {
          numPageAll = tri91BookAll[0].bookPagesTotal;
          bookTitleTri91 = tri91BookAll[0].bookTitleTri;
          triCatage = tri91BookAll[0].bookDetail;
          bookReadall = tri91BookAll[0].bookReadall;
          bookLastAccess = tri91BookAll[0].bookLastAccess;
          bookLastPages = tri91BookAll[0].bookLastPages;
          bookLastLine = tri91BookAll[0].bookLastLine;
        });
      } else {
        triCatage = 'โหลดข้อมูล...';
        bookTitleTri91 = 'โหลดข้อมูล...';
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error occurred: $e');
      // Show a user-friendly error message if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ATextDiskplayMedium(
          text: 'เล่ม $bookid $bookTitleTri91',
        ),
      ),
      body: SizedBox(
        //color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2, //_size.width >= 750 ? 2 : 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/bookcover/tripitaka91_book${widget.triBookid}.png',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: ATextTitleLarge(
                                text: 'เล่ม $bookid $bookTitleTri91'),
                          ),
                          Expanded(
                            flex: 4,
                            child: ATextTitleMedium(text: '[ $triCatage ]'),
                          ),
                          Expanded(
                            flex: 1,
                            child: ATextTitleMedium(
                              text:
                                  'มีทั้งหมด $numPageAll หน้า', // อ่านแล้ว $bookReadall หน้า',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            lastBookAccess.isEmpty
                ? const Text('')
                : TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.orange),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Tri91PageView(
                            triBookid: widget.triBookid,
                            triPageid: int.parse(
                              lastBookAccess[0].pageLastAccess.toString(),
                            ),
                            triBookline: '1',
                            chkSearch: '',
                          ),
                        ),
                      );
                    },
                    child: ATextDiskplayMedium(
                      text:
                          'เปิดหน้าที่อ่านล่าสุด เล่ม ${lastBookAccess[0].bookLastAccess} หน้า ${lastBookAccess[0].pageLastAccess}',
                    ),
                  ),
            const SizedBox(height: 10),
            const Row(
              children: <Widget>[
                Icon(
                  Icons.book,
                  size: 20,
                  color: Colors.blue,
                ),
                ATextBodyMedium(text: ' สารบัญหัวข้อธรรม'),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              flex: 4,
              child: SearchShowPagesTitleList(
                bookid: widget.triBookid,
                isMobile: widget.isMobile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
