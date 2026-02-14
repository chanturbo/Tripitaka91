import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/models/rand_title.dart';
import 'package:tripitaka91/utils/models/totalsearchtitle.dart';
import 'package:tripitaka91/utils/models/totalsearchtri.dart';
import 'package:tripitaka91/utils/models/tri91_booksearch.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/line_custom/mylinepainter.dart';
import 'package:tripitaka91/widget/search/search_show_dict.dart';
import 'package:tripitaka91/widget/search/search_show_dictbt.dart';
import 'package:tripitaka91/widget/search/search_show_title.dart';
import 'package:tripitaka91/widget/search/search_show_titlerandom.dart';
import 'package:tripitaka91/widget/search/search_show_tri91.dart';
import 'package:tripitaka91/widget/search/search_show_tri91_onpage.dart';

class SearchTabShow extends StatelessWidget {
  final String title;
  final List<String> result;
  final List<String> resultDetail;
  final int indexShow;
  final bool isM;
  final bool online;
  final bool volumeHelper;
  const SearchTabShow({
    super.key,
    required this.title,
    required this.result,
    required this.resultDetail,
    required this.indexShow,
    required this.isM,
    required this.online,
    required this.volumeHelper,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyTabPage(
        indexShow: indexShow,
        title: title,
        pages: [
          MyPageTabDetail(
            title: title,
            indexLocal: 0,
            result: result,
            resultDetail: resultDetail,
            isM: isM,
            online: online,
            volumeHelper: volumeHelper,
          ),
          MyPageTabDetail(
            title: title,
            indexLocal: 1,
            result: result,
            resultDetail: resultDetail,
            isM: isM,
            online: online,
            volumeHelper: volumeHelper,
          ),
          MyPageTabDetail(
            title: title,
            indexLocal: 2,
            result: result,
            resultDetail: resultDetail,
            isM: isM,
            online: online,
            volumeHelper: volumeHelper,
          ),
          MyPageTabDetail(
            title: title,
            indexLocal: 3,
            result: result,
            resultDetail: resultDetail,
            isM: isM,
            online: online,
            volumeHelper: volumeHelper,
          ),
          MyPageTabDetail(
            title: title,
            indexLocal: 4,
            result: result,
            resultDetail: resultDetail,
            isM: isM,
            online: online,
            volumeHelper: volumeHelper,
          ),
          MyPageTabDetail(
            title: title,
            indexLocal: 5,
            result: result,
            resultDetail: resultDetail,
            isM: isM,
            online: online,
            volumeHelper: volumeHelper,
          ),
          if (online || volumeHelper)
            MyPageTabDetail(
              title: title,
              indexLocal: 6,
              result: result,
              resultDetail: resultDetail,
              isM: isM,
              online: online,
              volumeHelper: volumeHelper,
            ),
        ],
        result: result,
        isM: isM,
        online: online,
        volumeHelper: volumeHelper,
      ),
    );
  }
}

class MyTabPage extends StatelessWidget {
  final int indexShow;
  final String title;
  final List<MyPageTabDetail> pages;
  final List<String> result;
  final bool isM;
  final bool online;
  final bool volumeHelper;

  const MyTabPage({
    super.key,
    required this.indexShow,
    required this.title,
    required this.pages,
    required this.result,
    required this.isM,
    required this.online,
    required this.volumeHelper,
  });

  @override
  Widget build(BuildContext context) {
    List<String> results = result;
    return DefaultTabController(
      initialIndex: indexShow,
      length: pages.length,
      child: Scaffold(
        appBar: AppBar(
          title: ATextDiskplayMedium(text: 'ผลการค้นหาคำว่า \'$title\''),
          bottom: TabBar(
            indicatorColor: TColors.secondary,
            isScrollable: true,
            tabs: [
              Tab(
                child: isM
                    ? ATextDiskplayLargeBlack(
                        text: 'หัวข้อธรรมสำคัญ [ ${results[0]} ]',
                      )
                    : ATextDiskplaySmallBlack(
                        text: 'หัวข้อธรรมสำคัญ [ ${results[0]} ]',
                      ),
              ),
              Tab(
                child: isM
                    ? ATextDiskplayLargeBlack(
                        text: 'พระวินัยปิฎก [ ${results[1]} ]',
                      )
                    : ATextDiskplaySmallBlack(
                        text: 'พระวินัยปิฎก [ ${results[1]} ]',
                      ),
              ),
              Tab(
                child: isM
                    ? ATextDiskplayLargeBlack(
                        text: 'พระสุตันตปิฎก [ ${results[2]} ]',
                      )
                    : ATextDiskplaySmallBlack(
                        text: 'พระสุตันตปิฎก [ ${results[2]} ]',
                      ),
              ),
              Tab(
                child: isM
                    ? ATextDiskplayLargeBlack(
                        text: 'พระอภิธรรมปิฎก [ ${results[3]} ]',
                      )
                    : ATextDiskplaySmallBlack(
                        text: 'พระอภิธรรมปิฎก [ ${results[3]} ]',
                      ),
              ),
              Tab(
                child: isM
                    ? ATextDiskplayLargeBlack(
                        text: 'ประมวลศัพท์ [ ${results[4]} ]',
                      )
                    : ATextDiskplaySmallBlack(
                        text: 'ประมวลศัพท์ [ ${results[4]} ]',
                      ),
              ),
              Tab(
                child: isM
                    ? ATextDiskplayLargeBlack(
                        text: 'พจนานุกรมไทย-บาลี [ ${results[5]} ]',
                      )
                    : ATextDiskplaySmallBlack(
                        text: 'พจนานุกรมไทย-บาลี [ ${results[5]} ]',
                      ),
              ),
              if (online || volumeHelper)
                Tab(
                  child: isM
                      ? const ATextDiskplayLargeBlack(
                          text: 'ค้นหาจากคำใกล้เคียง [ 1+ ]',
                        )
                      : const ATextDiskplaySmallBlack(
                          text: 'ค้นหาจากคำใกล้เคียง [ 1+ ]',
                        ),
                ),
            ],
          ),
        ),
        body: TabBarView(children: pages.map((page) => page).toList()),
      ),
    );
  }
}

class MyPageTabDetail extends StatefulWidget {
  final String title;
  final int indexLocal;
  final List<String> result;
  final List<String> resultDetail;
  final bool isM;
  final bool online;
  final bool volumeHelper;

  const MyPageTabDetail({
    super.key,
    required this.title,
    required this.indexLocal,
    required this.result,
    required this.resultDetail,
    required this.isM,
    required this.online,
    required this.volumeHelper,
  });

  @override
  State<MyPageTabDetail> createState() => _MyPageTabDetailState();
}

class _MyPageTabDetailState extends State<MyPageTabDetail>
    with AutomaticKeepAliveClientMixin {
  Future<String>? fetchData;
  Future<List<RandTitle?>>? fetchDataTitle;
  Future<List<Tri91BookSearch>>? fetchDataTri1;

  int indexlocal = 0;
  List<RandTitle> randTitle = [];
  TotalTitleSearch? randDict;
  TotalTitleSearchTri? randTri;
  String bookSearchid1 = '0';
  String bookSearchid2 = '0';
  String bookSearchid3 = '0';
  int? selectBookSearchIndex1 = 0;
  int? selectBookSearchIndex2 = 0;
  int? selectBookSearchIndex3 = 0;
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  ScrollController _scrollController3 = ScrollController();
  double scrollBookSearchIndexs1 = -1;
  double scrollBookSearchIndexs2 = -1;
  double scrollBookSearchIndexs3 = -1;

  @override
  void initState() {
    super.initState();
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    _scrollController3 = ScrollController();
    indexlocal = widget.indexLocal;
    if (indexlocal == 0) {
    } else if (indexlocal == 1) {
      loadDataTri1();
    } else if (indexlocal == 2) {
      loadDataTri2();
    } else if (indexlocal == 3) {
      loadDataTri3();
    } else if (indexlocal == 4) {
      //fetchDict();
    } else if (indexlocal == 5) {
      //fetchDictbt();
    }
  }

  Future<TotalTitleSearchTri?> loadDataTri1() async {
    /* randTri = widget.online
        ? await RemoteServiceTri91SearchTotal().getBookTri91(
            "1",
            "10",
            widget.title,
            tSecretAPIKey,
          )
        : await DatabaseHelper().getBook91SearchSet1(widget.title);
    return randTri;*/
    return filterByRange(widget.resultDetail[0], 1, 10);
  }

  Future<TotalTitleSearchTri?> loadDataTri2() async {
    /*randTri = widget.online
        ? await RemoteServiceTri91SearchTotal().getBookTri91(
            "11",
            "74",
            widget.title,
            tSecretAPIKey,
          )
        : await DatabaseHelper().getBook91SearchSet2(widget.title);
    return randTri;*/
    return filterByRange(widget.resultDetail[0], 11, 74);
  }

  Future<TotalTitleSearchTri?> loadDataTri3() async {
    /*randTri = widget.online
        ? await RemoteServiceTri91SearchTotal().getBookTri91(
            "75",
            "91",
            widget.title,
            tSecretAPIKey,
          )
        : await DatabaseHelper().getBook91SearchSet3(widget.title);
    return randTri;*/
    return filterByRange(widget.resultDetail[0], 75, 91);
  }

  /*
  Future<TotalTitleSearch?> fetchDict() async {
    randDict = await RemoteServiceDictSearchTotal().getTitle(
      widget.title,
      tSecretAPIKey,
    );
    return randDict;
  }

  Future<TotalTitleSearch?> fetchDictbt() async {
    randDict = await RemoteServiceDictbtSearchTotal().getTitle(
      widget.title,
      tSecretAPIKey,
    );

    return randDict;
  }
*/
  TotalTitleSearchTri filterByRange(String source, int start, int end) {
    // แยกข้อมูลทั้งหมด
    List<String> items = source.split("|");
    List<String> filtered = [];
    int sum = 0;

    // วนคัดช่วง
    for (var item in items) {
      List<String> parts = item.split("#");
      if (parts.length != 2) continue;

      int front = int.tryParse(parts[0]) ?? -1;
      int value = int.tryParse(parts[1]) ?? 0;

      // ✅ เพิ่มเงื่อนไข: ตรวจสอบว่าอยู่ในช่วงและค่าไม่เป็น 0
      if (front >= start && front <= end && value != 0) {
        filtered.add(item);
        sum += value;
      }
    }

    // ถ้าไม่มีข้อมูลเลย
    if (filtered.isEmpty) {
      return TotalTitleSearchTri(totalRecords: 0, detailRecords: "");
    }

    // return ปกติ
    return TotalTitleSearchTri(
      totalRecords: sum,
      detailRecords: filtered.join("|"),
    );
  }

  void _scrollToSelectedIndex1() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController1.hasClients && scrollBookSearchIndexs1 != -1) {
        _scrollController1.animateTo(
          scrollBookSearchIndexs1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _scrollToSelectedIndex2() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController2.hasClients && scrollBookSearchIndexs2 != -1) {
        _scrollController2.animateTo(
          scrollBookSearchIndexs2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _scrollToSelectedIndex3() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController3.hasClients && scrollBookSearchIndexs3 != -1) {
        _scrollController3.animateTo(
          scrollBookSearchIndexs3,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String getNikayaName(int bookNo) {
    if (bookNo >= 1 && bookNo <= 4) {
      return '[ มหาวิภังค์ ]';
    } else if (bookNo == 5) {
      return '[ ภิกขุนีวิภังค์ ]';
    } else if (bookNo >= 6 && bookNo <= 7) {
      return '[ มหาวรรค ]';
    } else if (bookNo >= 8 && bookNo <= 9) {
      return '[ จุลวรรค ]';
    } else if (bookNo == 10) {
      return '[ ปริวาร ]';
    } else if (bookNo >= 11 && bookNo <= 16) {
      return '[ ทีฆนิกาย ]';
    } else if (bookNo >= 17 && bookNo <= 23) {
      return '[ มัชฌิมนิกาย ]';
    } else if (bookNo >= 24 && bookNo <= 31) {
      return '[ สังยุตตนิกาย ]';
    } else if (bookNo >= 32 && bookNo <= 38) {
      return '[ อังคุตตรนิกาย ]';
    } else if (bookNo >= 39 && bookNo <= 74) {
      return '[ ขุททกนิกาย ]';
    } else if (bookNo >= 75 && bookNo <= 76) {
      return '[ ธรรมสังคณี ]';
    } else if (bookNo >= 77 && bookNo <= 78) {
      return '[ วิภังค์ ]';
    } else if (bookNo == 79) {
      return '[ ธาตุกถา-บุคคลบัญญัติ ]';
    } else if (bookNo >= 80 && bookNo <= 81) {
      return '[ กถาวัตถุ ]';
    } else if (bookNo >= 82 && bookNo <= 84) {
      return '[ ยมก ]';
    } else if (bookNo >= 85 && bookNo <= 91) {
      return '[ ปัฏฐาน ]';
    } else {
      return '-';
    }
  }
  // ===============================================================
  // ฟังก์ชันใหม่: แยกข้อมูลและจัดกลุ่มตามนิกาย
  // ===============================================================

  /// แยกข้อมูลจาก string และจัดกลุ่มตามนิกาย
  /// Input: "11#14|12#29|13#19|..."
  /// Output: Map ที่จัดกลุ่มตามชื่อนิกาย
  Map<String, List<Map<String, dynamic>>> parseAndGroupByNikaya(String data) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    // แยกข้อมูลด้วย |
    List<String> entries = data.split('|');

    for (String entry in entries) {
      if (entry.trim().isEmpty) continue;

      // แยกเลขเล่มและจำนวน
      List<String> parts = entry.split('#');
      if (parts.length == 2) {
        int bookNo = int.parse(parts[0].trim());
        int count = int.parse(parts[1].trim());

        String nikayaName = getNikayaName(bookNo);

        // เพิ่มข้อมูลลงในกลุ่ม
        if (!groupedData.containsKey(nikayaName)) {
          groupedData[nikayaName] = [];
        }

        groupedData[nikayaName]!.add({'book': bookNo, 'count': count});
      }
    }

    return groupedData;
  }

  /// แปลงข้อมูลที่จัดกลุ่มแล้วเป็น List พร้อม subtitle (header)
  /// จะสร้างรายการที่มีทั้ง header และ item สลับกัน
  List<Map<String, dynamic>> convertGroupedDataToList(
    Map<String, List<Map<String, dynamic>>> groupedData,
  ) {
    List<Map<String, dynamic>> result = [];

    groupedData.forEach((nikayaName, books) {
      // เพิ่ม header (subtitle)
      result.add({'type': 'header', 'nikaya': nikayaName});

      // เพิ่มข้อมูลเล่มในหมวดนั้น
      for (var book in books) {
        result.add({
          'type': 'item',
          'book': book['book'].toString(),
          'page': book['count'].toString(),
          'nikaya': nikayaName,
        });
      }
    });

    return result;
  }

  /// Scroll ไปยัง subtitle (nikaya) ที่ต้องการสำหรับ ScrollController1
  void _scrollToNikaya1(
    String targetNikaya,
    List<Map<String, dynamic>> dataList,
  ) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_scrollController1.hasClients) return;

      int targetIndex = -1;
      for (int i = 0; i < dataList.length; i++) {
        if (dataList[i]['type'] == 'header' &&
            dataList[i]['nikaya'] == targetNikaya) {
          targetIndex = i;
          break;
        }
      }

      if (targetIndex != -1) {
        // คำนวณ offset โดยประมาณ (header = 48px, item = 72px)
        double estimatedOffset = 0;
        for (int i = 0; i < targetIndex; i++) {
          estimatedOffset += dataList[i]['type'] == 'header' ? 48.0 : 72.0;
        }

        _scrollController1.animateTo(
          estimatedOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Scroll ไปยัง subtitle (nikaya) ที่ต้องการสำหรับ ScrollController2
  void _scrollToNikaya2(
    String targetNikaya,
    List<Map<String, dynamic>> dataList,
  ) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_scrollController2.hasClients) return;

      int targetIndex = -1;
      for (int i = 0; i < dataList.length; i++) {
        if (dataList[i]['type'] == 'header' &&
            dataList[i]['nikaya'] == targetNikaya) {
          targetIndex = i;
          break;
        }
      }

      if (targetIndex != -1) {
        double estimatedOffset = 0;
        for (int i = 0; i < targetIndex; i++) {
          estimatedOffset += dataList[i]['type'] == 'header' ? 48.0 : 72.0;
        }

        _scrollController2.animateTo(
          estimatedOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Scroll ไปยัง subtitle (nikaya) ที่ต้องการสำหรับ ScrollController3
  void _scrollToNikaya3(
    String targetNikaya,
    List<Map<String, dynamic>> dataList,
  ) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_scrollController3.hasClients) return;

      int targetIndex = -1;
      for (int i = 0; i < dataList.length; i++) {
        if (dataList[i]['type'] == 'header' &&
            dataList[i]['nikaya'] == targetNikaya) {
          targetIndex = i;
          break;
        }
      }

      if (targetIndex != -1) {
        double estimatedOffset = 0;
        for (int i = 0; i < targetIndex; i++) {
          estimatedOffset += dataList[i]['type'] == 'header' ? 48.0 : 72.0;
        }

        _scrollController3.animateTo(
          estimatedOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// สร้างปุ่มเลือกนิกายสำหรับ Desktop
  List<Widget> _buildNikayaButtons(
    List<Map<String, dynamic>> dataList,
    Function(String) onNikayaTap,
  ) {
    Set<String> nikayas = {};
    for (var item in dataList) {
      if (item['type'] == 'header') {
        nikayas.add(item['nikaya']);
      }
    }

    return nikayas.map((nikaya) {
      return Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: ElevatedButton(
          onPressed: () => onNikayaTap(nikaya),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            nikaya.replaceAll('[', '').replaceAll(']', '').trim(),
            style: TextStyle(
              fontSize: widget.isM ? 14 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// สร้างปุ่มเลือกนิกายสำหรับ Mobile (ขนาดเล็กกว่า)
  List<Widget> _buildNikayaButtonsMobile(
    List<Map<String, dynamic>> dataList,
    Function(String) onNikayaTap,
  ) {
    Set<String> nikayas = {};
    for (var item in dataList) {
      if (item['type'] == 'header') {
        nikayas.add(item['nikaya']);
      }
    }

    return nikayas.map((nikaya) {
      return Padding(
        padding: const EdgeInsets.only(right: 6, bottom: 6),
        child: InkWell(
          onTap: () => onNikayaTap(nikaya),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              nikaya.replaceAll('[', '').replaceAll(']', '').trim(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  /// สร้าง Header (Subtitle) Widget
  Widget _buildNikayaHeader(String nikayaName) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.isM ? 8 : 10, // ← แก้ไขบรรทัดนี้
        horizontal: widget.isM ? 8 : 10,
      ),
      child: Row(
        children: [
          Icon(Icons.book, color: Colors.blue[900], size: widget.isM ? 16 : 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              nikayaName,
              style: TextStyle(
                fontSize: widget.isM ? 14.0 : 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    super.build(context);
    String wordSearch = widget.title;
    RegExp regex = RegExp(r'\s+');
    List<String> outputList = wordSearch.split(regex);

    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(2.5),
        child: indexlocal == 0
            ? widget.result[0] == '0'
                  ? const Text('ไม่พบข้อมูลสำหรับแสดงผล')
                  : SearchShowPagesTitle(
                      wordSearch: wordSearch,
                      isM: widget.isM,
                      online: widget.online,
                    )
            : indexlocal == 1
            ? FutureBuilder<TotalTitleSearchTri?>(
                future: loadDataTri1(),
                builder: (context, snapshot) {
                  double screenWidth = MediaQuery.of(context).size.width;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // กำลังโหลดข้อมูล
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // กรณีเกิดข้อผิดพลาด
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    TotalTitleSearchTri? totalTitleSearch = snapshot.data;
                    if (totalTitleSearch?.totalRecords != 0) {
                      String detail = totalTitleSearch!.detailRecords;

                      // ✨ ใช้ฟังก์ชันใหม่: แยกและจัดกลุ่มตามนิกาย
                      Map<String, List<Map<String, dynamic>>> groupedData =
                          parseAndGroupByNikaya(detail);
                      List<Map<String, dynamic>> dataList =
                          convertGroupedDataToList(groupedData);

                      // ตั้งค่า bookSearchid1 เริ่มต้น
                      if (bookSearchid1 == '0' && dataList.isNotEmpty) {
                        for (var item in dataList) {
                          if (item['type'] == 'item') {
                            bookSearchid1 = item['book'];
                            break;
                          }
                        }
                      }

                      return widget.isM
                          ? Column(
                              children: [
                                // ✨ ปุ่มเลือกนิกายสำหรับ Mobile
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'เลือกหมวด:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 80,
                                        child: SingleChildScrollView(
                                          child: Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: _buildNikayaButtonsMobile(
                                              dataList,
                                              (nikaya) => _scrollToNikaya1(
                                                nikaya,
                                                dataList,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // ListView พร้อม Header
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollController1,
                                    itemCount: dataList.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> data =
                                          dataList[index];

                                      if (data['type'] == 'header') {
                                        return _buildNikayaHeader(
                                          data['nikaya'],
                                        );
                                      } else {
                                        String strBook = data['book'];
                                        String strTotal =
                                            'เล่ม $strBook พบจำนวน ${data['page']} รายการ';

                                        return Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SearchShowPages(
                                                          title: strTotal,
                                                          wordSearch:
                                                              widget.title,
                                                          bookid: strBook,
                                                          isM: widget.isM,
                                                          catalog:
                                                              'พระวินัยปิฎก',
                                                          online: widget.online,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.blue[900],
                                                      foregroundColor:
                                                          Colors.white,
                                                      radius: 20,
                                                      child: Text(
                                                        strBook,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SubstringHighlight(
                                                            text: strTotal,
                                                            terms: outputList,
                                                            textStyle:
                                                                const TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.chevron_right,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 1,
                                              color: Colors.grey[300],
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      // ✨ ปุ่มเลือกนิกาย
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'เลือกหมวด:',
                                              style: TextStyle(
                                                fontSize: widget.isM ? 16 : 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height:
                                                  80, // จำกัดความสูงเพื่อให้เลื่อนได้
                                              child: SingleChildScrollView(
                                                child: Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: _buildNikayaButtons(
                                                    dataList,
                                                    (nikaya) =>
                                                        _scrollToNikaya1(
                                                          nikaya,
                                                          dataList,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // ListView พร้อม Header
                                      Expanded(
                                        child: ListView.builder(
                                          controller: _scrollController1,
                                          itemCount: dataList.length,
                                          itemBuilder: (context, index) {
                                            Map<String, dynamic> data =
                                                dataList[index];

                                            if (data['type'] == 'header') {
                                              return _buildNikayaHeader(
                                                data['nikaya'],
                                              );
                                            } else {
                                              String strBook = data['book'];
                                              String strTotal =
                                                  'เล่ม $strBook พบจำนวน ${data['page']} รายการ';

                                              return Column(
                                                children: [
                                                  Container(
                                                    color:
                                                        selectBookSearchIndex1 ==
                                                            index
                                                        ? Colors.yellow
                                                        : Colors.transparent,
                                                    child: ListTile(
                                                      leading: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.blue[900],
                                                        foregroundColor:
                                                            Colors.white,
                                                        child: Text(strBook),
                                                      ),
                                                      title: SubstringHighlight(
                                                        text: strTotal,
                                                        terms: outputList,
                                                        textStyle: TextStyle(
                                                          fontSize: widget.isM
                                                              ? 18.0
                                                              : 16.0,
                                                          color: Colors.black,
                                                        ),
                                                      ),

                                                      onTap: () {
                                                        setState(() {
                                                          bookSearchid1 =
                                                              strBook;
                                                          selectBookSearchIndex1 =
                                                              index;
                                                          scrollBookSearchIndexs1 =
                                                              _scrollController1
                                                                  .offset;
                                                          _scrollToSelectedIndex1();
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  const Divider(height: 1),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: CustomPaint(
                                    painter: MyVerticalLinePainter(),
                                    size: Size(0.5, screenHeight),
                                  ),
                                ),
                                Expanded(
                                  flex: screenWidth > 1440 ? 4 : 3,
                                  child: SearchShowPagesOnPage(
                                    title: '',
                                    wordSearch: widget.title,
                                    bookid: bookSearchid1,
                                    isM: widget.isM,
                                    catalog: 'พระวินัยปิฎก',
                                    online: widget.online,
                                  ),
                                ),
                              ],
                            );
                    } else {
                      return const Text('ไม่พบข้อมูลสำหรับแสดงผล');
                    }
                  } else {
                    return const Text('ไม่พบข้อมูลสำหรับแสดงผล');
                  }
                },
              )
            : indexlocal == 2
            ? FutureBuilder<TotalTitleSearchTri?>(
                future: loadDataTri2(),
                builder: (context, snapshot) {
                  double screenWidth = MediaQuery.of(context).size.width;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // กำลังโหลดข้อมูล
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // กรณีเกิดข้อผิดพลาด
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    TotalTitleSearchTri? totalTitleSearch = snapshot.data;
                    if (totalTitleSearch?.totalRecords != 0) {
                      String detail = totalTitleSearch!.detailRecords;

                      // ✨ ใช้ฟังก์ชันใหม่: แยกและจัดกลุ่มตามนิกาย
                      Map<String, List<Map<String, dynamic>>> groupedData =
                          parseAndGroupByNikaya(detail);
                      List<Map<String, dynamic>> dataList =
                          convertGroupedDataToList(groupedData);

                      // ตั้งค่า bookSearchid2 เริ่มต้น
                      if (bookSearchid2 == '0' && dataList.isNotEmpty) {
                        for (var item in dataList) {
                          if (item['type'] == 'item') {
                            bookSearchid2 = item['book'];
                            break;
                          }
                        }
                      }

                      return widget.isM
                          ? Column(
                              children: [
                                // ✨ ปุ่มเลือกนิกายสำหรับ Mobile
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'เลือกหมวด:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 80,
                                        child: SingleChildScrollView(
                                          child: Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: _buildNikayaButtonsMobile(
                                              dataList,
                                              (nikaya) => _scrollToNikaya2(
                                                nikaya,
                                                dataList,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // ListView พร้อม Header
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollController2,
                                    itemCount: dataList.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> data =
                                          dataList[index];

                                      if (data['type'] == 'header') {
                                        return _buildNikayaHeader(
                                          data['nikaya'],
                                        );
                                      } else {
                                        String strBook = data['book'];
                                        String strTotal =
                                            'เล่ม $strBook พบจำนวน ${data['page']} รายการ';

                                        return Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SearchShowPages(
                                                          title: strTotal,
                                                          wordSearch:
                                                              widget.title,
                                                          bookid: strBook,
                                                          isM: widget.isM,
                                                          catalog:
                                                              'พระสุตตันตปิฎก',
                                                          online: widget.online,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.blue[900],
                                                      foregroundColor:
                                                          Colors.white,
                                                      radius: 20,
                                                      child: Text(
                                                        strBook,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SubstringHighlight(
                                                            text: strTotal,
                                                            terms: outputList,
                                                            textStyle:
                                                                const TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.chevron_right,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 1,
                                              color: Colors.grey[300],
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      // ✨ ปุ่มเลือกนิกาย
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'เลือกหมวด:',
                                              style: TextStyle(
                                                fontSize: widget.isM ? 16 : 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 80,
                                              child: SingleChildScrollView(
                                                child: Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: _buildNikayaButtons(
                                                    dataList,
                                                    (nikaya) =>
                                                        _scrollToNikaya2(
                                                          nikaya,
                                                          dataList,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // ListView พร้อม Header
                                      Expanded(
                                        child: ListView.builder(
                                          controller: _scrollController2,
                                          itemCount: dataList.length,
                                          itemBuilder: (context, index) {
                                            Map<String, dynamic> data =
                                                dataList[index];

                                            if (data['type'] == 'header') {
                                              return _buildNikayaHeader(
                                                data['nikaya'],
                                              );
                                            } else {
                                              String strBook = data['book'];
                                              String strTotal =
                                                  'เล่ม $strBook พบจำนวน ${data['page']} รายการ';

                                              return Column(
                                                children: [
                                                  Container(
                                                    color:
                                                        selectBookSearchIndex2 ==
                                                            index
                                                        ? Colors.yellow
                                                        : Colors.transparent,
                                                    child: ListTile(
                                                      leading: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.blue[900],
                                                        foregroundColor:
                                                            Colors.white,
                                                        child: Text(strBook),
                                                      ),
                                                      title: SubstringHighlight(
                                                        text: strTotal,
                                                        terms: outputList,
                                                        textStyle: TextStyle(
                                                          fontSize: widget.isM
                                                              ? 18.0
                                                              : 16.0,
                                                          color: Colors.black,
                                                        ),
                                                      ),

                                                      onTap: () {
                                                        setState(() {
                                                          bookSearchid2 =
                                                              strBook;
                                                          selectBookSearchIndex2 =
                                                              index;
                                                          scrollBookSearchIndexs2 =
                                                              _scrollController2
                                                                  .offset;
                                                          _scrollToSelectedIndex2();
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  const Divider(height: 1),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: CustomPaint(
                                    painter: MyVerticalLinePainter(),
                                    size: Size(0.5, screenHeight),
                                  ),
                                ),
                                Expanded(
                                  flex: screenWidth > 1440 ? 4 : 3,
                                  child: SearchShowPagesOnPage(
                                    title: '',
                                    wordSearch: widget.title,
                                    bookid: bookSearchid2,
                                    isM: widget.isM,
                                    catalog: 'พระสุตตันตปิฎก',
                                    online: widget.online,
                                  ),
                                ),
                              ],
                            );
                    } else {
                      return const Text('ไม่พบข้อมูลสำหรับแสดงผล');
                    }
                  } else {
                    return const Text('ไม่พบข้อมูลสำหรับแสดงผล');
                  }
                },
              )
            : indexlocal == 3
            ? FutureBuilder<TotalTitleSearchTri?>(
                future: loadDataTri3(),
                builder: (context, snapshot) {
                  double screenWidth = MediaQuery.of(context).size.width;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // กำลังโหลดข้อมูล
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // กรณีเกิดข้อผิดพลาด
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    TotalTitleSearchTri? totalTitleSearch = snapshot.data;
                    if (totalTitleSearch?.totalRecords != 0) {
                      String detail = totalTitleSearch!.detailRecords;

                      // ✨ ใช้ฟังก์ชันใหม่: แยกและจัดกลุ่มตามนิกาย
                      Map<String, List<Map<String, dynamic>>> groupedData =
                          parseAndGroupByNikaya(detail);
                      List<Map<String, dynamic>> dataList =
                          convertGroupedDataToList(groupedData);

                      // ตั้งค่า bookSearchid3 เริ่มต้น
                      if (bookSearchid3 == '0' && dataList.isNotEmpty) {
                        for (var item in dataList) {
                          if (item['type'] == 'item') {
                            bookSearchid3 = item['book'];
                            break;
                          }
                        }
                      }

                      return widget.isM
                          ? Column(
                              children: [
                                // ✨ ปุ่มเลือกนิกายสำหรับ Mobile
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'เลือกหมวด:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 80,
                                        child: SingleChildScrollView(
                                          child: Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: _buildNikayaButtonsMobile(
                                              dataList,
                                              (nikaya) => _scrollToNikaya3(
                                                nikaya,
                                                dataList,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // ListView พร้อม Header
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollController3,
                                    itemCount: dataList.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> data =
                                          dataList[index];

                                      if (data['type'] == 'header') {
                                        return _buildNikayaHeader(
                                          data['nikaya'],
                                        );
                                      } else {
                                        String strBook = data['book'];
                                        String strTotal =
                                            'เล่ม $strBook พบจำนวน ${data['page']} รายการ';

                                        return Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SearchShowPages(
                                                          title: strTotal,
                                                          wordSearch:
                                                              widget.title,
                                                          bookid: strBook,
                                                          isM: widget.isM,
                                                          catalog:
                                                              'พระอภิธรรมปิฎก',
                                                          online: widget.online,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.blue[900],
                                                      foregroundColor:
                                                          Colors.white,
                                                      radius: 20,
                                                      child: Text(
                                                        strBook,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SubstringHighlight(
                                                            text: strTotal,
                                                            terms: outputList,
                                                            textStyle:
                                                                const TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.chevron_right,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 1,
                                              color: Colors.grey[300],
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      // ✨ ปุ่มเลือกนิกาย
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'เลือกหมวด:',
                                              style: TextStyle(
                                                fontSize: widget.isM ? 16 : 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 80,
                                              child: SingleChildScrollView(
                                                child: Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: _buildNikayaButtons(
                                                    dataList,
                                                    (nikaya) =>
                                                        _scrollToNikaya3(
                                                          nikaya,
                                                          dataList,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // ListView พร้อม Header
                                      Expanded(
                                        child: ListView.builder(
                                          controller: _scrollController3,
                                          itemCount: dataList.length,
                                          itemBuilder: (context, index) {
                                            Map<String, dynamic> data =
                                                dataList[index];

                                            if (data['type'] == 'header') {
                                              return _buildNikayaHeader(
                                                data['nikaya'],
                                              );
                                            } else {
                                              String strBook = data['book'];
                                              String strTotal =
                                                  'เล่ม $strBook พบจำนวน ${data['page']} รายการ';

                                              return Column(
                                                children: [
                                                  Container(
                                                    color:
                                                        selectBookSearchIndex3 ==
                                                            index
                                                        ? Colors.yellow
                                                        : Colors.transparent,
                                                    child: ListTile(
                                                      leading: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.blue[900],
                                                        foregroundColor:
                                                            Colors.white,
                                                        child: Text(strBook),
                                                      ),
                                                      title: SubstringHighlight(
                                                        text: strTotal,
                                                        terms: outputList,
                                                        textStyle: TextStyle(
                                                          fontSize: widget.isM
                                                              ? 18.0
                                                              : 16.0,
                                                          color: Colors.black,
                                                        ),
                                                      ),

                                                      onTap: () {
                                                        setState(() {
                                                          bookSearchid3 =
                                                              strBook;
                                                          selectBookSearchIndex3 =
                                                              index;
                                                          scrollBookSearchIndexs3 =
                                                              _scrollController3
                                                                  .offset;
                                                          _scrollToSelectedIndex3();
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  const Divider(height: 1),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: CustomPaint(
                                    painter: MyVerticalLinePainter(),
                                    size: Size(0.5, screenHeight),
                                  ),
                                ),
                                Expanded(
                                  flex: screenWidth > 1440 ? 4 : 3,
                                  child: SearchShowPagesOnPage(
                                    title: '',
                                    wordSearch: widget.title,
                                    bookid: bookSearchid3,
                                    isM: widget.isM,
                                    catalog: 'พระอภิธรรมปิฎก',
                                    online: widget.online,
                                  ),
                                ),
                              ],
                            );
                    } else {
                      return const Text('ไม่พบข้อมูลสำหรับแสดงผล');
                    }
                  } else {
                    return const Text('ไม่พบข้อมูลสำหรับแสดงผล');
                  }
                },
              )
            : indexlocal == 4
            ? widget.result[4] == '0'
                  ? const Text('ไม่พบข้อมูลสำหรับแสดงผล')
                  : SearchShowPagesDict(
                      wordSearch: wordSearch,
                      isM: widget.isM,
                      online: widget.online,
                    )
            : indexlocal == 5
            ? widget.result[5] == '0'
                  ? const Text('ไม่พบข้อมูลสำหรับแสดงผล')
                  : SearchShowPagesDictbt(
                      wordSearch: wordSearch,
                      isM: widget.isM,
                      online: widget.online,
                    )
            : indexlocal == 6
            ? widget.result[6] == '0'
                  ? const Text('ไม่พบข้อมูลสำหรับแสดงผล')
                  : SearchShowPagesTitleRandom(
                      wordSearch: wordSearch,
                      isM: widget.isM,
                      online: widget.online,
                    )
            : FutureBuilder(
                future: fetchData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Center(child: Text(snapshot.data.toString()));
                  }
                },
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
