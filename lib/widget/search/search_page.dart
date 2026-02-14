import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/db_helper/db_helper.dart';
import 'package:tripitaka91/utils/models/totalsearchtitle.dart';
import 'package:tripitaka91/utils/models/totalsearchtri.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/search/search_tab_show.dart';

class SearchPages extends StatefulWidget {
  final bool isM;
  final String title;
  final bool online;
  final bool volumeHelper;
  const SearchPages({
    super.key,
    required this.title,
    required this.isM,
    required this.online,
    required this.volumeHelper,
  });

  @override
  State<SearchPages> createState() => _SearchPagesState();
}

class _SearchPagesState extends State<SearchPages> {
  TotalTitleSearch? randTitle;
  TotalTitleSearch? randTitle1;
  TotalTitleSearch? randDict;
  TotalTitleSearch? randDict1;
  TotalTitleSearch? randDictbt;
  TotalTitleSearchTri? randTri;
  TotalTitleSearchTri? randTri1, randTri5, randTri6, randTri8, randTri10;
  TotalTitleSearchTri? randTri11, randTri17, randTri24, randTri32, randTri39;
  TotalTitleSearchTri? randTri75,
      randTri77,
      randTri79,
      randTri80,
      randTri82,
      randTri85;
  List<String> titleMenu = ["0", "0", "0", "0", "0", "0"];
  List<String> listResultsDetail = ["0"];
  final ValueNotifier<int> vinayaTotal = ValueNotifier<int>(0);
  final ValueNotifier<int> suttantaTotal = ValueNotifier<int>(0);
  final ValueNotifier<int> abhidhammaTotal = ValueNotifier<int>(0);

  final dbhelper = DatabaseHelper();
  Map<String, dynamic> jsonData = {"set1": {}, "set2": {}, "set3": {}};

  // ฟังก์ชันที่ใช้สำหรับอัปเดตข้อมูลในดัชนีที่ระบุ
  void updateData(int index, String newValue) {
    if (index >= 0 && index < titleMenu.length) {
      final oldValue = int.tryParse(titleMenu[index]) ?? 0;
      final addValue = int.tryParse(newValue) ?? 0;

      titleMenu[index] = (oldValue + addValue).toString();
    }
  }

  void updateResults(List<String> listResults, String newInput) {
    // ฟังก์ชันตรวจ format
    bool isValidFormat(String item) {
      final regex = RegExp(r'^\d+#\d+$');
      return regex.hasMatch(item);
    }

    // แยกข้อมูลใหม่
    List<String> newItems = newInput.split("|");

    // กรองเฉพาะที่ถูก format
    newItems = newItems.where((e) => isValidFormat(e)).toList();

    // ถ้าไม่มีข้อมูลถูกต้องเลย → ไม่ต้องทำอะไร
    if (newItems.isEmpty) return;

    // ถ้ายังเป็นค่าเริ่มต้น
    if (listResults[0] == "0") {
      listResults[0] = newItems.join("|");
      return;
    }

    // แยกข้อมูลเดิม
    List<String> oldItems = listResults[0].split("|");

    // กันซ้ำ + รวม
    Set<String> merged = {};
    merged.addAll(oldItems);
    merged.addAll(newItems);

    // sort ตามเลขหน้า #
    List<String> sortedList = merged.toList()
      ..sort((a, b) {
        int aNum = int.parse(a.split("#")[0]);
        int bNum = int.parse(b.split("#")[0]);

        return aNum.compareTo(bNum);
      });

    // รวมกลับ
    listResults[0] = sortedList.join("|");
    //print('listResults = ${listResults[0]}');
  }

  @override
  void initState() {
    super.initState();
    widget.online
        ? fetchSearchHistoryFromAPI()
        : dbhelper.saveHisSearch(widget.title, jsonData);
    if (widget.online || widget.volumeHelper) {
      titleMenu.add("1");
    }
    loadSequentially();
  }

  Future<void> loadSequentially() async {
    // Load each Future in sequence and update state after each completes
    randTitle1 = await fetchDataTitle();
    setState(() {});
    randTri1 = await fetchDataTri1(1, 4);
    setState(() {});
    randTri5 = await fetchDataTri1(5, 5);
    setState(() {});
    randTri6 = await fetchDataTri1(6, 7);
    setState(() {});
    randTri8 = await fetchDataTri1(8, 9);
    setState(() {});
    randTri10 = await fetchDataTri1(10, 10);
    setState(() {});
    randTri11 = await fetchDataTri2(11, 16);
    setState(() {});
    randTri17 = await fetchDataTri2(17, 23);
    setState(() {});
    randTri24 = await fetchDataTri2(24, 31);
    setState(() {});
    randTri32 = await fetchDataTri2(32, 38);
    setState(() {});
    randTri39 = await fetchDataTri2(39, 74);
    setState(() {});
    randTri75 = await fetchDataTri3(75, 76);
    setState(() {});
    randTri77 = await fetchDataTri3(77, 78);
    setState(() {});
    randTri79 = await fetchDataTri3(79, 79);
    setState(() {});
    randTri80 = await fetchDataTri3(80, 81);
    setState(() {});
    randTri82 = await fetchDataTri3(82, 84);
    setState(() {});
    randTri85 = await fetchDataTri3(85, 91);
    setState(() {});
    randDict1 = await fetchDict();
    setState(() {});
  }

  Widget titleByMode(String text, bool isM) {
    return isM ? ATextTitleMedium18(text: text) : ATextTitleLarge(text: text);
  }

  Widget buildListTri(
    TotalTitleSearchTri? data,
    String titleTri,
    int indexShow,
    String label,
    ValueNotifier<int> totalCounter,
  ) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    int total = data.totalRecords;

    if (total <= 0) {
      return const SizedBox.shrink();
    }

    /// ✅ บวกเข้าผลรวม (กันบวกซ้ำ)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      totalCounter.value += total;
    });

    return Container(
      padding: const EdgeInsets.all(5),
      alignment: Alignment.bottomLeft,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),

        title: widget.isM
            ? ATextTitleMedium18(text: '$titleTri พบจำนวน $total รายการ')
            : ATextTitleLarge(text: '$titleTri พบจำนวน $total รายการ'),
        onTap: total > 0
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchTabShow(
                      title: widget.title,
                      result: titleMenu,
                      resultDetail: listResultsDetail,
                      indexShow: indexShow,
                      isM: widget.isM,
                      online: widget.online,
                      volumeHelper: widget.volumeHelper,
                    ),
                  ),
                );
              }
            : null,
      ),
    );
  }

  Widget buildListTitle(
    TotalTitleSearch? data,
    String titleTri,
    int indexShow,
  ) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    int total = data.totalRecords;

    return Container(
      padding: const EdgeInsets.all(5),
      alignment: Alignment.bottomLeft,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: total > 0 ? Colors.blue[900] : Colors.grey,
          foregroundColor: Colors.white,
          child: Text(total.toString()),
        ),
        title: widget.isM
            ? ATextTitleMedium18(text: '$titleTri พบจำนวน $total รายการ')
            : ATextTitleLarge(text: '$titleTri พบจำนวน $total รายการ'),
        onTap: total > 0
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchTabShow(
                      title: widget.title,
                      result: titleMenu,
                      resultDetail: listResultsDetail,
                      indexShow: indexShow,
                      isM: widget.isM,
                      online: widget.online,
                      volumeHelper: widget.volumeHelper,
                    ),
                  ),
                );
              }
            : null, // ปิดการใช้งาน onTap ถ้าไม่มีข้อมูล
      ),
    );
  }

  Widget buildListDict(
    TotalTitleSearch? data,
    String titleDict,
    int indexShow,
  ) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    int total = data.totalRecords;

    return Container(
      padding: const EdgeInsets.all(5),
      alignment: Alignment.bottomLeft,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: total > 0 ? Colors.blue[900] : Colors.grey,
              foregroundColor: Colors.white,
              child: Text(total.toString()),
            ),
            title: widget.isM
                ? ATextTitleMedium18(text: '$titleDict พบจำนวน $total รายการ')
                : ATextTitleLarge(text: '$titleDict พบจำนวน $total รายการ'),
            onTap: total > 0
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchTabShow(
                          title: widget.title,
                          result: titleMenu,
                          resultDetail: listResultsDetail,
                          indexShow: indexShow,
                          isM: widget.isM,
                          online: widget.online,
                          volumeHelper: widget.volumeHelper,
                        ),
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Future<bool> fetchSearchHistoryFromAPI() async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }
    final response = await http.post(
      Uri.parse(tURLLogSearch),
      body: {
        "token": tSecretAPIKey,
        "action": "save",
        "username": tmpUser,
        "keyword": widget.title,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(json);
      bool successValue = decodedJson['success'];
      // print(data);

      // print(dummyDataList.length);
      return successValue;
    } else {
      return false;
    }
  }

  Future<TotalTitleSearch?> fetchDataTitle() async {
    randTitle = widget.online
        ? await RemoteServiceTitleSearchTotal().getTitle(
            widget.title,
            tSecretAPIKey,
          )
        : await dbhelper.getTri91TitleSearchDB(
            widget.title.replaceAll(' ', '%'),
          );
    updateData(0, randTitle!.totalRecords.toString());
    return randTitle;
  }

  Future<TotalTitleSearch?> fetchDict() async {
    randDict = widget.online
        ? await RemoteServiceDictSearchTotal().getTitle(
            widget.title,
            tSecretAPIKey,
          )
        : await dbhelper.getTriDictSearchDB(widget.title.replaceAll(' ', '%'));
    updateData(4, randDict!.totalRecords.toString());
    return randDict;
  }

  Future<TotalTitleSearch?> fetchDictbt() async {
    randDictbt = randDict = widget.online
        ? await RemoteServiceDictbtSearchTotal().getTitle(
            widget.title,
            tSecretAPIKey,
          )
        : await dbhelper.getTriDictBtSearchDB(
            widget.title.replaceAll(' ', '%'),
          );
    updateData(5, randDictbt!.totalRecords.toString());
    return randDictbt;
  }

  Future<TotalTitleSearchTri?> fetchDataTri1(int bookstart, int bookend) async {
    randTri = widget.online
        ? await RemoteServiceTri91SearchTotalSplit().getBookTri91(
            bookstart.toString(),
            bookend.toString(),
            widget.title,
            tSecretAPIKey,
          )
        : await dbhelper.getBooks91_1SearchCount(
            widget.title.replaceAll(' ', '%'),
            bookid: bookstart,
            bookidend: bookend,
          );

    updateData(1, randTri!.totalRecords.toString());
    updateResults(listResultsDetail, randTri!.detailRecords.toString());
    return randTri;
  }

  Future<TotalTitleSearchTri?> fetchDataTri2(int bookstart, int bookend) async {
    randTri = widget.online
        ? await RemoteServiceTri91SearchTotalSplit().getBookTri91(
            bookstart.toString(),
            bookend.toString(),
            widget.title,
            tSecretAPIKey,
          )
        : await dbhelper.getBooks91_2SearchCount(
            widget.title.replaceAll(' ', '%'),
            bookid: bookstart,
            bookidend: bookend,
          );
    updateData(2, randTri!.totalRecords.toString());
    updateResults(listResultsDetail, randTri!.detailRecords.toString());
    return randTri;
  }

  Future<TotalTitleSearchTri?> fetchDataTri3(int bookstart, int bookend) async {
    randTri = widget.online
        ? await RemoteServiceTri91SearchTotalSplit().getBookTri91(
            bookstart.toString(),
            bookend.toString(),
            widget.title,
            tSecretAPIKey,
          )
        : await dbhelper.getBooks91_3SearchCount(
            widget.title.replaceAll(' ', '%'),
            bookid: bookstart,
            bookidend: bookend,
          );
    updateData(3, randTri!.totalRecords.toString());
    updateResults(listResultsDetail, randTri!.detailRecords.toString());
    return randTri;
  }

  @override
  Widget build(BuildContext context) {
    String wordSearch = widget.title;
    return Scaffold(
      appBar: AppBar(
        title: ATextDiskplayLarge(text: 'ผลการค้นหาคำว่า \'$wordSearch\''),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(2.5),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      buildListTitle(randTitle1, 'หัวข้อธรรมสำคัญ', 0),

                      const Divider(),
                      ValueListenableBuilder<int>(
                        valueListenable: vinayaTotal,
                        builder: (context, total, _) {
                          return ListTile(
                            title: titleByMode(
                              total == 0
                                  ? '[ พระวินัยปิฎก พบจำนวน 0 รายการ ]'
                                  : '[ พระวินัยปิฎก ]',
                              widget.isM,
                            ),
                          );
                        },
                      ),
                      buildListTri(
                        randTri1,
                        'มหาวิภังค์',
                        1,
                        "เล่ม 1-4",
                        vinayaTotal,
                      ),
                      buildListTri(
                        randTri5,
                        'ภิกขุนีวิภังค์',
                        1,
                        "เล่ม 5",
                        vinayaTotal,
                      ),
                      buildListTri(
                        randTri6,
                        'มหาวรรค',
                        1,
                        "เล่ม 6-7",
                        vinayaTotal,
                      ),
                      buildListTri(
                        randTri8,
                        'จุลวรรค',
                        1,
                        "เล่ม 8-9",
                        vinayaTotal,
                      ),
                      buildListTri(
                        randTri10,
                        'ปริวาร',
                        1,
                        "เล่ม 10",
                        vinayaTotal,
                      ),

                      const Divider(),
                      ValueListenableBuilder<int>(
                        valueListenable: suttantaTotal,
                        builder: (context, total, _) {
                          return ListTile(
                            title: titleByMode(
                              total == 0
                                  ? '[ พระสุตตันตปิฎก พบจำนวน 0 รายการ ]'
                                  : '[ พระสุตตันตปิฎก ]',
                              widget.isM,
                            ),
                          );
                        },
                      ),
                      buildListTri(
                        randTri11,
                        'ทีฆนิกาย',
                        2,
                        "เล่ม 11-16",
                        suttantaTotal,
                      ),
                      buildListTri(
                        randTri17,
                        'มัชฌิมนิกาย',
                        2,
                        "เล่ม 17-23",
                        suttantaTotal,
                      ),
                      buildListTri(
                        randTri24,
                        'สังยุตตนิกาย',
                        2,
                        "เล่ม 24-31",
                        suttantaTotal,
                      ),
                      buildListTri(
                        randTri32,
                        'อังคุตตรนิกาย',
                        2,
                        "เล่ม 32-38",
                        suttantaTotal,
                      ),
                      buildListTri(
                        randTri39,
                        'ขุททกนิกาย',
                        2,
                        "เล่ม 39-74",
                        suttantaTotal,
                      ),

                      const Divider(),
                      ValueListenableBuilder<int>(
                        valueListenable: abhidhammaTotal,
                        builder: (context, total, _) {
                          return ListTile(
                            title: titleByMode(
                              total == 0
                                  ? '[ พระอภิธรรมปิฎก พบจำนวน 0 รายการ ]'
                                  : '[ พระอภิธรรมปิฎก ]',
                              widget.isM,
                            ),
                          );
                        },
                      ),
                      buildListTri(
                        randTri75,
                        'ธรรมสังคณี',
                        3,
                        "เล่ม 75-76",
                        abhidhammaTotal,
                      ),
                      buildListTri(
                        randTri77,
                        'วิภังค์',
                        3,
                        "เล่ม 77-78",
                        abhidhammaTotal,
                      ),
                      buildListTri(
                        randTri79,
                        'ธาตุกถา-บุคคลบัญญัติ',
                        3,
                        "เล่ม 79",
                        abhidhammaTotal,
                      ),
                      buildListTri(
                        randTri80,
                        'กถาวัตถุ',
                        3,
                        "เล่ม 80-81",
                        abhidhammaTotal,
                      ),
                      buildListTri(
                        randTri82,
                        'ยมก',
                        3,
                        "เล่ม 82-84",
                        abhidhammaTotal,
                      ),
                      buildListTri(
                        randTri85,
                        'ปัฏฐาน',
                        3,
                        "เล่ม 85-91",
                        abhidhammaTotal,
                      ),
                      const Divider(),
                      buildListDict(randDict1, 'พจนานุกรม ฉบับประมวลศัพท์', 4),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.bottomLeft,
                        child: FutureBuilder<TotalTitleSearch?>(
                          future: fetchDictbt(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // กำลังโหลดข้อมูล
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              // กรณีเกิดข้อผิดพลาด
                              return Text('Error: ${snapshot.error}');
                            } else {
                              TotalTitleSearch? totalTitleSearch =
                                  snapshot.data;
                              int total = totalTitleSearch!.totalRecords;
                              if (total > 0) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue[900],
                                    foregroundColor: Colors.white,
                                    child: Text(total.toString()),
                                  ),
                                  title: widget.isM
                                      ? ATextTitleMedium18(
                                          text:
                                              'พจนานุกรม ไทย-บาลี พบจำนวน $total รายการ',
                                        )
                                      : ATextTitleLarge(
                                          text:
                                              'พจนานุกรม ไทย-บาลี พบจำนวน $total รายการ',
                                        ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchTabShow(
                                          title: wordSearch,
                                          result: titleMenu,
                                          resultDetail: listResultsDetail,
                                          indexShow: 5,
                                          isM: widget.isM,
                                          online: widget.online,
                                          volumeHelper: widget.volumeHelper,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                    child: Text(total.toString()),
                                  ),
                                  title: widget.isM
                                      ? ATextTitleMedium18(
                                          text:
                                              'พจนานุกรม ไทย-บาลี พบจำนวน $total รายการ',
                                        )
                                      : ATextTitleMedium(
                                          text:
                                              'พจนานุกรม ไทย-บาลี พบจำนวน $total รายการ',
                                        ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const Divider(),
                      if (widget.online || widget.volumeHelper)
                        Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.bottomLeft,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[900],
                              foregroundColor: Colors.white,
                              child: const Text('1+'),
                            ),
                            title: widget.isM
                                ? const ATextTitleMedium18(
                                    text: 'ค้นหาจากคำใกล้เคียง จำนวน 1+ รายการ',
                                  )
                                : const ATextTitleLarge(
                                    text: 'ค้นหาจากคำใกล้เคียง จำนวน 1+ รายการ',
                                  ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchTabShow(
                                    title: wordSearch,
                                    result: titleMenu,
                                    resultDetail: listResultsDetail,
                                    indexShow: 6,
                                    isM: widget.isM,
                                    online: widget.online,
                                    volumeHelper: widget.volumeHelper,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (widget.online || widget.volumeHelper) const Divider(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
