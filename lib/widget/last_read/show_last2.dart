import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/models/last_book_access.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/bookshow/bookshow_title.dart';

class DummyLastBookAccessData2 extends StatefulWidget {
  final bool isMobile;
  const DummyLastBookAccessData2({super.key, required this.isMobile});

  @override
  State<DummyLastBookAccessData2> createState() =>
      _DummyLastBookAccessData2State();
}

class _DummyLastBookAccessData2State extends State<DummyLastBookAccessData2> {
  GetLastRead getLastRead = GetLastRead();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LastBookAccess>>(
      future: getLastRead.fetchLastBookAccessList(), // ใส่ username ที่ต้องการ
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(), // หากกำลังโหลดข้อมูล
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'), // หากเกิดข้อผิดพลาด
          );
        } else {
          // หากข้อมูลได้รับสำเร็จ
          List<LastBookAccess> lastBookAccessList = snapshot.data ?? [];

          // นำ lastBookAccessList ไปใช้ในการสร้าง widget ตามความต้องการ
          return Expanded(
            child: SizedBox(
              height: 35.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: lastBookAccessList.length,
                itemBuilder: (BuildContext context, int index) {
                  LastBookAccess lastBookAccess = lastBookAccessList[index];
                  // print(
                  //     '${lastBookAccess.bookLastAccess} ${lastBookAccess.timeLastAccess.toString()}');
                  return SizedBox(
                    width: 70,
                    child: Card(
                      margin: const EdgeInsets.all(5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookShowTitle(
                                triBookid:
                                    lastBookAccess.bookLastAccess.toString(),
                                chkSearch: "",
                              ),
                            ),
                          );
                        },
                        child: Center(
                          child: widget.isMobile
                              ? ATextTitleMedium(
                                  text: 'เล่ม ${lastBookAccess.bookLastAccess}')
                              : ATextLabelLarge(
                                  text:
                                      'เล่ม ${lastBookAccess.bookLastAccess}'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}
