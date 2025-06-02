import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:share_plus/share_plus.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/db_helper/db_helper.dart';
import 'package:tripitaka91/utils/img_service/shared_image_generator.dart';
import 'package:tripitaka91/utils/models/last_book_access.dart';
import 'package:tripitaka91/utils/models/rand_title.dart';
import 'package:tripitaka91/utils/models/tri91_bookall.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/audio/edit_speak.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/show_title_list.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/widget/pageviews/pageviews_html.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';
import 'package:tripitaka91/widget/volume_helper/volume_helper.dart';

class BookShowTitle extends StatefulWidget {
  final String triBookid;
  final String chkSearch;
  final bool isMobile;
  final bool online;
  const BookShowTitle({
    super.key,
    required this.triBookid,
    required this.chkSearch,
    required this.isMobile,
    required this.online,
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
  List<String> dataTitle = [];
  int loadedRecordsTitle = 0;
  bool loadingTitle = false;
  int pageTitle = 1;
  bool hasMoreData = true; // ตัวแปรใหม่เพื่อตรวจสอบว่ามีข้อมูลเพิ่มเติมหรือไม่

  final dbHelper = DatabaseHelper();
  late TextTitleReplace textTitleReplace;
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  final SharedImageGenerator sharedImageGenerator = SharedImageGenerator();
  Users? usersChk;
  final SharedImageLocal sharedImageLocal = SharedImageLocal();
  final volumeHelper = VolumeHelper();

  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();
    _getUser();
    _getLastBook();
    getDataTri91();
    widget.online ? _fetchDataTitle() : _fetchDataTitleInBook();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchDataTitleInBook() async {
    int recordsPerPage = 10;
    if (!loadingTitle && hasMoreData) {
      setState(() {
        loadingTitle = true;
      });

      try {
        List<String> newData = await DatabaseHelper().fetchTitlesInBook(
          widget.triBookid,
          (pageTitle - 1) * recordsPerPage,
          recordsPerPage,
        );

        if (newData.isEmpty) {
          // หากไม่มีข้อมูลเพิ่มเติมให้โหลด
          setState(() {
            hasMoreData = false; // ตั้งค่าให้ไม่มีข้อมูลเพิ่มเติม
            loadingTitle = false;
          });
          return; // ออกจากฟังก์ชัน
        }

        setState(() {
          loadedRecordsTitle += newData.length;
          dataTitle.addAll(newData);
          loadingTitle = false;
          pageTitle++;
        });
      } catch (e) {
        // ignore: avoid_print
        print('Database Error: $e');
        setState(() {
          hasMoreData = false;
          loadingTitle = false;
        });
      }
    }
  }

  Future<void> _fetchDataTitle() async {
    if (!loadingTitle && hasMoreData) {
      setState(() {
        loadingTitle = true;
      });

      Users? users = await getUsersList();
      String tmpUser = 'guest';
      if (users != null) {
        tmpUser = users.username;
      }

      final response = await http.post(
        Uri.parse(tURLtitleShowInPage),
        body: {
          'bookid': widget.triBookid,
          'token': tSecretAPIKey,
          'username': tmpUser,
          'page': pageTitle.toString(),
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

        if (jsonResponse['success'] == true) {
          List<String> newData = List<String>.from(jsonResponse['message']);

          if (newData.isEmpty) {
            // หากไม่มีข้อมูลเพิ่มเติมให้โหลด
            setState(() {
              hasMoreData = false; // ตั้งค่าให้ไม่มีข้อมูลเพิ่มเติม
              loadingTitle = false;
            });
            return; // ออกจากฟังก์ชัน
          }
          setState(() {
            loadedRecordsTitle += newData.length;
            dataTitle.addAll(newData);
            loadingTitle = false;
            pageTitle++;
          });
        } else {
          // ignore: use_build_context_synchronously
          _showSnackbar(context, '${jsonResponse['message']}');
          setState(() {
            hasMoreData = false;
            loadingTitle = false;
          });
        }
      } else {
        // ignore: avoid_print
        print('HTTP Error: ${response.statusCode}');
      }
    }
  }

  Future<void> _getUser() async {
    users = await getUsersList();
    usersChk = users;
  }

  void _handleLastBookAccess(bool isMobile) async {
    // แสดง Dialog โหลดข้อมูล
    showDialog(
      context: context,
      barrierDismissible: false, // ไม่ให้กดปิดจนกว่าจะโหลดเสร็จ
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("กำลังโหลดข้อมูล..."),
            ],
          ),
        );
      },
    );

    // ดึงข้อมูล
    await _getLastBook();

    // ปิด Dialog เมื่อโหลดเสร็จ
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    int lastInt = 1;

    // ถ้าไม่มีข้อมูลให้แจ้งเตือน
    if (lastBookAccess.isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ไม่พบหน้าที่อ่านล่าสุด")),
      );
    } else {
      lastInt = int.parse(lastBookAccess[0].pageLastAccess.toString());
    }

    // แสดง Dialog ยืนยัน
    // ignore: use_build_context_synchronously
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ยืนยันการเปิดหน้า"),
          content: Text("คุณต้องการเปิดหน้าที่ $lastInt ใช่หรือไม่?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // ยกเลิก
              child: const Text("ยกเลิก"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // ยืนยัน
              child: const Text("ยืนยัน"),
            ),
          ],
        );
      },
    );

    // ถ้าผู้ใช้กดยืนยัน ให้นำทางไปยังหน้าใหม่
    if (confirm == true) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Tri91PageViewHtml(
            triBookid: widget.triBookid,
            triPageid: lastInt,
            triBookline: '1',
            chkSearch: '',
            isMobile: isMobile,
            online: widget.online,
          ),
        ),
      );
    }
  }

  Future<void> _getLastBook() async {
    if (widget.online) {
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
    } else {
      List<LastBookAccess> dbLastBookAccess =
          await dbHelper.getLastReadWithBook(widget.triBookid);
      lastBookAccess = dbLastBookAccess;
    }
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

  void getDataTri91() async {
    try {
      tri91BookAll = (widget.online
          ? await RemoteServiceBookTri91All()
                  .getBookTri91All(widget.triBookid, tSecretAPIKey) ??
              []
          : await dbHelper.getBookTri91All(widget.triBookid))!;
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

  Widget _showText(String title, String mark) {
    if (mark == 'TRUE') {
      return Text(
        title,
        style:
            TextStyle(fontSize: widget.isMobile ? 18 : 16, color: Colors.red),
      );
    } else {
      return widget.isMobile
          ? ATextTitleMedium18(
              text: title,
            )
          : ATextTitleMedium(
              text: title,
            );
    }
  }

  void _showInputDialog(BuildContext context, String initialText,
      String tripitaka91No, String tripitaka91Code) {
    final TextEditingController textController =
        TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(5),
          title: const Text(
            'แก้ไขข้อมูลหัวข้อธรรม (สำหรับ Admin เท่านั้น)',
            style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
          ),
          content: TextFormField(
            style: const TextStyle(fontFamily: 'THSarabunNew', fontSize: 26),
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'กรอกข้อมูลที่นี่',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดหน้าต่าง
              },
              child: const Text(
                'ยกเลิก',
                style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (usersChk != null) {
                  // ทำสิ่งที่ต้องการเมื่อกดปุ่มบันทึกข้อมูล
                  String inputData = textController.text;
                  if (inputData == '') {
                    _showSnackbar(context, 'กรุณาป้อนข้อมูลให้ครบถ้วน');
                  } else {
                    // อาจทำการใช้ข้อมูลที่ป้อนเข้ามาต่อไป
                    // print(
                    //     'ข้อมูลที่ป้อน: $inputData เล่ม $bookid หน้า $bookpage บรรทัด $bookline');
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm!) {
                      await _fetchUpdateTitle(
                          inputData, tripitaka91No, tripitaka91Code);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop(); // ปิดหน้าต่าง
                    }
                  }
                } else {
                  _showSnackbar(context, 'กรุณาเข้าสู่ระบบก่อน');
                  Navigator.of(context).pop(); // ปิดหน้าต่าง
                }
              },
              child: const Text(
                ' บันทึกข้อมูล ',
                style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchUpdateTitle(
      String initialText, String tripitaka91No, String tripitaka91Code) async {
    final response = await http.post(
      Uri.parse(tURLtitleEdit),
      body: {
        'token': tSecretAPIKey,
        'tripitaka91no': tripitaka91No,
        'tripitaka91code': tripitaka91Code,
        'titledetail': initialText,
        'username': usersChk!.username,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        dataTitle = [];
        loadedRecordsTitle = 0;
        loadingTitle = false;
        pageTitle = 1;
        widget.online ? _fetchDataTitle() : _fetchDataTitleInBook();
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'บันทึกข้อมูลเรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการดำเนินการ'),
          content: const Text('คุณต้องการดำเนินการต่อ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // ปิดหน้าต่างและส่งค่า false กลับ
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // ปิดหน้าต่างและส่งค่า true กลับ
              },
              child: const Text(' ยืนยัน '),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isMobile
        ? Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(
                        left: 72.0, bottom: 16.0), // ปรับซ้ายให้พ้นลูกศร
                    title: ATextTitleMediumColor(
                      text: 'เล่ม $bookid $bookTitleTri91',
                      color: TColors.white,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/images/bookcover/tripitaka91_book${widget.triBookid}.png',
                                  width: 100,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ATextTitleMedium(text: '[ $triCatage ]'),
                                    ATextTitleMedium(
                                        text: 'มีทั้งหมด $numPageAll หน้า'),
                                    if (lastBookAccess.isNotEmpty)
                                      TextButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  Colors.orange),
                                        ),
                                        onPressed: () {
                                          _handleLastBookAccess(
                                              widget.isMobile);
                                        },
                                        child: const ATextDiskplayMedium(
                                          text:
                                              'เปิดหน้าที่อ่านล่าสุด', // เล่ม ${lastBookAccess[0].bookLastAccess} หน้า ${lastBookAccess[0].pageLastAccess}',
                                        ),
                                      ),
                                    const SizedBox(height: 5),
                                    TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                                Colors.orange),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            TextEditingController
                                                pageController =
                                                TextEditingController();
                                            String?
                                                errorMessage; // ข้อความแจ้งเตือน

                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return AlertDialog(
                                                  title:
                                                      const Text('ป้อนเลขหน้า'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        controller:
                                                            pageController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              "เลขหน้าที่ต้องการ",
                                                          errorText:
                                                              errorMessage, // แสดงข้อความแจ้งเตือน
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context), // ปิด dialog
                                                      child:
                                                          const Text('ยกเลิก'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        if (pageController
                                                            .text.isNotEmpty) {
                                                          int pageNumber =
                                                              int.tryParse(
                                                                      pageController
                                                                          .text) ??
                                                                  1;

                                                          if (pageNumber < 1 ||
                                                              pageNumber >
                                                                  numPageAll) {
                                                            // อัปเดตข้อความแจ้งเตือน
                                                            setState(() {
                                                              errorMessage =
                                                                  "กรุณาป้อนเลขหน้า 1 - $numPageAll";
                                                            });
                                                          } else {
                                                            Navigator.pop(
                                                                context); // ปิด dialog

                                                            // เปิดหน้าใหม่โดยใช้ bookid เดิม และเปลี่ยนเฉพาะ pageid
                                                            //bool? returned = await
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Tri91PageViewHtml(
                                                                  triBookid: widget
                                                                      .triBookid, // ใช้ค่าเดิม
                                                                  triPageid:
                                                                      pageNumber, // ใช้ค่าที่ป้อนมา
                                                                  triBookline:
                                                                      '1',
                                                                  chkSearch: '',
                                                                  isMobile: widget
                                                                      .isMobile,
                                                                  online: widget
                                                                      .online,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      },
                                                      child:
                                                          const Text('ยืนยัน'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: const ATextDiskplayMedium(
                                        text: 'เปิดระบุหน้า',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.book,
                              size: 20,
                              color: Colors.blue,
                            ),
                            const ATextBodyMedium(text: ' สารบัญหัวข้อธรรม'),
                            const SizedBox(width: 10),
                            IconButton(
                              color: Colors.black,
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                String code = widget.triBookid;
                                String linkPhp = 'tripitaka91_1.php';
                                Clipboard.setData(
                                  ClipboardData(
                                      text:
                                          '$tURLmain$linkPhp?book_code=$code'),
                                );
                                _showSnackbar(
                                    context, 'คัดลอกข้อมูลเรียบร้อยแล้ว');
                              },
                            ),
                            IconButton(
                              color: Colors.black,
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                Share.share(
                                  'tripitaka91_1.php?book_code=${widget.triBookid}',
                                  subject:
                                      'สารบัญหัวข้อธรรม เล่ม ${widget.triBookid}',
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // print('index : $index < dataTitle : ${dataTitle.length}');
                      if (index < dataTitle.length) {
                        // จัดการข้อมูลที่จะแสดงใน ListTile
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[900],
                            foregroundColor: Colors.white,
                            child: ATextDiskplayMedium(text: '${index + 1}'),
                          ),
                          title: _showText(
                            '${textTitleReplace.extractText(dataTitle[index]).replaceAll(textTitleReplace.getBookBlue(dataTitle[index]), '')} ',
                            textTitleReplace.getMark(dataTitle[index]),
                          ),
                          subtitle: Column(
                            children: [
                              Row(
                                children: [
                                  widget.online || volumeHelper.showVolume
                                      ? InkWell(
                                          onTap: () async {
                                            LoadingDialog.show(context);
                                            String bookIds = textTitleReplace
                                                .getBookId(dataTitle[index]);
                                            String pageId = textTitleReplace
                                                .getPageId(dataTitle[index]);
                                            String bookLine = textTitleReplace
                                                .getLineId(dataTitle[index]);
                                            String noTitleCate =
                                                textTitleReplace
                                                    .getCate(dataTitle[index]);
                                            String noTitle = textTitleReplace
                                                .getNo(dataTitle[index]);

                                            String txtTitle =
                                                textTitleReplace.replaceText(
                                                    textTitleReplace
                                                        .extractText(
                                                            dataTitle[index]),
                                                    textTitleReplace
                                                        .getBookBlue(
                                                            dataTitle[index]));

                                            String filename =
                                                noTitleCate.replaceAll('.', '');
                                            filename =
                                                '$filename-$noTitle-$bookIds-$pageId-$bookLine';
                                            await audioPlayerManager.playAudio(
                                                '1', filename, txtTitle);

                                            // ignore: use_build_context_synchronously
                                            LoadingDialog.hide(context);
                                          },
                                          child: Icon(
                                            Icons.volume_up,
                                            size: widget.isMobile ? 25 : 20,
                                            color: Colors.blue[300],
                                          ),
                                        )
                                      : const Text(''),
                                  widget.online || volumeHelper.showVolume
                                      ? const SizedBox(width: 10)
                                      : const SizedBox.shrink(),
                                  InkWell(
                                    onTap: () async {
                                      String bookIds = textTitleReplace
                                          .getBookId(dataTitle[index]);
                                      String pageId = textTitleReplace
                                          .getPageId(dataTitle[index]);
                                      String bookLine = textTitleReplace
                                          .getLineId(dataTitle[index]);
                                      String txtTitle =
                                          '${textTitleReplace.extractText(dataTitle[index]).replaceAll(textTitleReplace.getBookBlue(dataTitle[index]), '')} ';
                                      // txtTitle +=
                                      //     'สรุปเนื้อความจากพระไตรปิฎก ฉบับ มมร. เล่ม $bookIds หน้า $pageId บรรทัด $bookLine';
                                      // await Share.share(
                                      //     '$txtTitle อ่านรายละเอียด -> $tURLmain$bookIds-$pageId-$bookLine.htm',
                                      //     subject: 'สรุปหัวข้อธรรมจากพระไตรปิฎก');
                                      sharedImageGenerator.generateAndShare(
                                        context: context,
                                        bookTitle: txtTitle.replaceAll('', ''),
                                        bookid: bookIds,
                                        pageid: pageId.toString(),
                                        lineid: bookLine,
                                        bookBlue: textTitleReplace
                                            .getBookBlue(dataTitle[index]),
                                        bookRed: textTitleReplace
                                            .getBookRed(dataTitle[index]),
                                      );
                                    },
                                    child: Icon(
                                      Icons.share,
                                      size: 16,
                                      color: Colors.blue[300],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () async {
                                      String bookIds = textTitleReplace
                                          .getBookId(dataTitle[index]);
                                      String pageId = textTitleReplace
                                          .getPageId(dataTitle[index]);
                                      String bookLine = textTitleReplace
                                          .getLineId(dataTitle[index]);
                                      String txtTitle =
                                          '${textTitleReplace.extractText(dataTitle[index]).replaceAll(textTitleReplace.getBookBlue(dataTitle[index]), '')} ';
                                      txtTitle +=
                                          'สรุปเนื้อความจากพระไตรปิฎก ฉบับ มมร. เล่ม $bookIds หน้า $pageId บรรทัด $bookLine';
                                      Clipboard.setData(
                                        ClipboardData(
                                            text:
                                                '$txtTitle อ่านรายละเอียด -> $tURLmain$bookIds-$pageId-$bookLine.htm'),
                                      );
                                      _showSnackbar(
                                          context, 'คัดลอกข้อมูลเรียบร้อยแล้ว');
                                    },
                                    child: Icon(
                                      Icons.copy,
                                      size: widget.isMobile ? 21 : 16,
                                      color: Colors.blue[300],
                                    ),
                                  ),
                                  (usersChk != null) &&
                                          (usersChk?.levelAccess == '1')
                                      ? const SizedBox(width: 10)
                                      : const SizedBox.shrink(),
                                  (usersChk != null) &&
                                          (usersChk?.levelAccess == '1')
                                      ? InkWell(
                                          onTap: () async {
                                            _showInputDialog(
                                              context,
                                              textTitleReplace.extractText(
                                                  dataTitle[index]),
                                              textTitleReplace
                                                  .getNo(dataTitle[index]),
                                              textTitleReplace
                                                  .getCate(dataTitle[index]),
                                            );
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            size: widget.isMobile ? 21 : 16,
                                            color: Colors.blue[300],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  (usersChk != null)
                                      ? const SizedBox(width: 10)
                                      : const SizedBox.shrink(),
                                  (usersChk != null)
                                      ? InkWell(
                                          onTap: () async {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  contentPadding:
                                                      const EdgeInsets.all(5),
                                                  title: const Text(
                                                      'แจ้งการอ่านออกเสียง'),
                                                  content: const SizedBox(
                                                    width: double.maxFinite,
                                                    child: EditSpeakScreen(
                                                      comments: '-',
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                          'ปิดหน้าจอ'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Icon(
                                            Icons.edit_document,
                                            size: widget.isMobile ? 21 : 16,
                                            color: Colors.blue[300],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  const Expanded(
                                    child: SizedBox(
                                      child: Text(''),
                                    ),
                                  ),
                                  widget.isMobile
                                      ? const SizedBox.shrink()
                                      : Align(
                                          alignment: Alignment.centerLeft,
                                          child: ClipPath(
                                            clipper:
                                                DoubleTriangleRectangleClipper(),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              color: Colors.blue[900],
                                              child: ATextLabelSmall(
                                                text:
                                                    '${textTitleReplace.extractRemainingText(dataTitle[index])} ',
                                              ),
                                            ),
                                          ),
                                        ),
                                  widget.isMobile
                                      ? const SizedBox.shrink()
                                      : const SizedBox(width: 10),
                                  widget.isMobile
                                      ? const SizedBox.shrink()
                                      : Align(
                                          alignment: Alignment.centerRight,
                                          child: ClipPath(
                                            clipper:
                                                DoubleTriangleRectangleClipper(),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              color: Colors
                                                  .red, // Change color as needed
                                              child: Center(
                                                child: ATextLabelSmall(
                                                  text:
                                                      'เล่มสีแดง ${textTitleReplace.getBookRed(dataTitle[index])}', // Access widget property
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              Row(
                                children: [
                                  widget.isMobile
                                      ? Align(
                                          alignment: Alignment.centerLeft,
                                          child: ClipPath(
                                            clipper:
                                                DoubleTriangleRectangleClipper(),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              color: Colors.blue[900],
                                              child: ATextLabelSmall(
                                                text:
                                                    '${textTitleReplace.extractRemainingText(dataTitle[index])} ',
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  widget.isMobile
                                      ? const SizedBox(width: 10)
                                      : const SizedBox.shrink(),
                                  widget.isMobile
                                      ? Align(
                                          alignment: Alignment.centerRight,
                                          child: ClipPath(
                                            clipper:
                                                DoubleTriangleRectangleClipper(),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              color: Colors
                                                  .red, // Change color as needed
                                              child: Center(
                                                child: ATextLabelSmall(
                                                  text:
                                                      'เล่มสีแดง ${textTitleReplace.getBookRed(dataTitle[index])}', // Access widget property
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              const Divider(),
                            ],
                          ),
                          onTap: () {
                            audioPlayerManager.stop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Tri91PageViewHtml(
                                  triBookid: textTitleReplace
                                      .getBookId(dataTitle[index]),
                                  triPageid: int.parse(textTitleReplace
                                      .getPageId(dataTitle[index])),
                                  triBookline: textTitleReplace
                                      .getLineId(dataTitle[index]),
                                  chkSearch: '',
                                  isMobile: widget.isMobile,
                                  online: widget.online,
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        // ตรวจสอบว่ามีข้อมูลเพิ่มเติมให้โหลดหรือไม่
                        if (hasMoreData) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            widget.online
                                ? _fetchDataTitle()
                                : _fetchDataTitleInBook();
                          });
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          if (pageTitle == 1) {
                            // print('pageTitle == $pageTitle');
                            return SizedBox(
                              child: Column(
                                children: [
                                  Center(
                                    child: ATextTitleLarge(
                                        text:
                                            'เล่ม ${widget.triBookid} ไม่พบหัวข้อธรรมสำหรับแสดงผล'),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  const Center(
                                    child: ATextTitleLarge(
                                        text:
                                            'กรุณาคลิกที่ปุ่มเปิดหน้าที่อ่านล่าสุด'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return const SizedBox(); // ไม่แสดงอะไรเมื่อไม่มีข้อมูลเพิ่มเติม
                        }
                      }
                    },
                    childCount: dataTitle.length +
                        1, // เพิ่ม 1 เพื่อแสดง Loader ถ้ายังมีข้อมูลเหลือ
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
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
                    flex: widget.isMobile ? 2 : 1, //_size.width >= 750 ? 2 : 1,
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
                          flex: 1,
                          child: Row(
                            children: <Widget>[
                              lastBookAccess.isEmpty
                                  ? const SizedBox.shrink()
                                  : TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                                Colors.orange),
                                      ),
                                      onPressed: () {
                                        _handleLastBookAccess(widget.isMobile);
                                      },
                                      child: const ATextDiskplayMedium(
                                        text:
                                            'เปิดหน้าที่อ่านล่าสุด', // เล่ม ${lastBookAccess[0].bookLastAccess} หน้า ${lastBookAccess[0].pageLastAccess}',
                                      ),
                                    ),
                              const SizedBox(width: 5),
                              TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.orange),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      TextEditingController pageController =
                                          TextEditingController();
                                      String? errorMessage; // ข้อความแจ้งเตือน

                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Text('ป้อนเลขหน้า'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: pageController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "เลขหน้าที่ต้องการ",
                                                    errorText:
                                                        errorMessage, // แสดงข้อความแจ้งเตือน
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context), // ปิด dialog
                                                child: const Text('ยกเลิก'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  if (pageController
                                                      .text.isNotEmpty) {
                                                    int pageNumber =
                                                        int.tryParse(
                                                                pageController
                                                                    .text) ??
                                                            1;

                                                    if (pageNumber < 1 ||
                                                        pageNumber >
                                                            numPageAll) {
                                                      // อัปเดตข้อความแจ้งเตือน
                                                      setState(() {
                                                        errorMessage =
                                                            "กรุณาป้อนเลขหน้า 1 - $numPageAll";
                                                      });
                                                    } else {
                                                      Navigator.pop(
                                                          context); // ปิด dialog

                                                      // เปิดหน้าใหม่โดยใช้ bookid เดิม และเปลี่ยนเฉพาะ pageid
                                                      //bool? returned = await
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Tri91PageViewHtml(
                                                            triBookid: widget
                                                                .triBookid, // ใช้ค่าเดิม
                                                            triPageid:
                                                                pageNumber, // ใช้ค่าที่ป้อนมา
                                                            triBookline: '1',
                                                            chkSearch: '',
                                                            isMobile:
                                                                widget.isMobile,
                                                            online:
                                                                widget.online,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: const Text('ยืนยัน'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                child: const ATextDiskplayMedium(
                                  text: 'เปิดระบุหน้า',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget.isMobile
                      ? const SizedBox(width: 10)
                      : const SizedBox.shrink(),
                  widget.isMobile
                      ? lastBookAccess.isEmpty
                          ? const SizedBox.shrink()
                          : TextButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors.orange),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Tri91PageViewHtml(
                                      triBookid: widget.triBookid,
                                      triPageid: int.parse(
                                        lastBookAccess[0]
                                            .pageLastAccess
                                            .toString(),
                                      ),
                                      triBookline: '1',
                                      chkSearch: '',
                                      isMobile: widget.isMobile,
                                      online: widget.online,
                                    ),
                                  ),
                                );
                              },
                              child: ATextDiskplayMedium(
                                text:
                                    'เปิดหน้าที่อ่านล่าสุด เล่ม ${lastBookAccess[0].bookLastAccess} หน้า ${lastBookAccess[0].pageLastAccess}',
                              ),
                            )
                      : const SizedBox.shrink(),
                  widget.isMobile
                      ? const SizedBox(height: 10)
                      : const SizedBox.shrink(),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.book,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const ATextBodyMedium(text: ' สารบัญหัวข้อธรรม'),
                      const SizedBox(width: 10),
                      IconButton(
                        color: Colors.black,
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          String code = widget.triBookid;
                          String linkPhp = 'tripitaka91_1.php';
                          Clipboard.setData(
                            ClipboardData(
                                text: '$tURLmain$linkPhp?book_code=$code'),
                          );
                          _showSnackbar(context, 'คัดลอกข้อมูลเรียบร้อยแล้ว');
                        },
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        color: Colors.black,
                        icon: const Icon(Icons.share),
                        onPressed: () async {
                          String code = widget.triBookid;
                          String linkPhp = 'tripitaka91_1.php';
                          await Share.share('$tURLmain$linkPhp?book_code=$code',
                              subject: 'สารบัญหัวข้อธรรม เล่ม $code');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    flex: widget.isMobile ? 4 : 3,
                    child: SearchShowPagesTitleList(
                      bookid: widget.triBookid,
                      isMobile: widget.isMobile,
                      online: widget.online,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void _showSnackbar(BuildContext context, String info) {
    final snackBar = SnackBar(
      content: Text(info),
      duration: const Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
