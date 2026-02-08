import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/totalsearchtitle.dart';
import 'package:tripitaka91/utils/models/totalsearchtri.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/search/search_tab_show.dart';

class SearchPages extends StatefulWidget {
  const SearchPages({super.key, required this.title, required this.isM});
  final bool isM;
  final String title;

  @override
  State<SearchPages> createState() => _SearchPagesState();
}

class _SearchPagesState extends State<SearchPages> {
  TotalTitleSearch? randTitle;
  TotalTitleSearch? randDict;
  TotalTitleSearch? randDictbt;
  TotalTitleSearchTri? randTri;
  List<String> titleMenu = ["0", "0", "0", "0", "0", "0", "1"];
  List<String> listResultsDetail = ["0"];
  final ValueNotifier<int> vinayaTotal = ValueNotifier<int>(0);
  final ValueNotifier<int> suttantaTotal = ValueNotifier<int>(0);
  final ValueNotifier<int> abhidhammaTotal = ValueNotifier<int>(0);

  void updateData(int index, String newValue) {
    if (index >= 0 && index < titleMenu.length) {
      final oldValue = int.tryParse(titleMenu[index]) ?? 0;
      final addValue = int.tryParse(newValue) ?? 0;

      titleMenu[index] = (oldValue + addValue).toString();
    }
  }

  void updateResults(
    List<String> listResults,
    String newInput,
  ) {
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
    // print(listResults[0]);
  }

  @override
  void initState() {
    super.initState();
    fetchSearchHistoryFromAPI();
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
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      bool successValue = decodedJson['success'];
      // print(data);

      // print(dummyDataList.length);
      return successValue;
    } else {
      return false;
    }
  }

  Future<TotalTitleSearch?> fetchDataTitle() async {
    randTitle = await RemoteServiceTitleSearchTotal()
        .getTitle(widget.title, tSecretAPIKey);
    updateData(0, randTitle!.totalRecords.toString());
    return randTitle;
  }

  Future<TotalTitleSearch?> fetchDict() async {
    randDict = await RemoteServiceDictSearchTotal()
        .getTitle(widget.title, tSecretAPIKey);
    updateData(4, randDict!.totalRecords.toString());
    return randDict;
  }

  Future<TotalTitleSearch?> fetchDictbt() async {
    randDictbt = await RemoteServiceDictbtSearchTotal()
        .getTitle(widget.title, tSecretAPIKey);
    updateData(5, randDictbt!.totalRecords.toString());
    return randDictbt;
  }

  Future<TotalTitleSearchTri?> fetchDataTri1() async {
    randTri = await RemoteServiceTri91SearchTotal()
        .getBookTri91("1", "10", widget.title, tSecretAPIKey);
    updateData(1, randTri!.totalRecords.toString());
    return randTri;
  }

  Future<TotalTitleSearchTri?> fetchDataTri2(String start, String end) async {
    randTri = await RemoteServiceTri91SearchTotal()
        .getBookTri91(start, end, widget.title, tSecretAPIKey);
    updateData(2, randTri!.totalRecords.toString());
    return randTri;
  }

  Future<TotalTitleSearchTri?> fetchDataTri3() async {
    randTri = await RemoteServiceTri91SearchTotal()
        .getBookTri91("75", "91", widget.title, tSecretAPIKey);
    updateData(3, randTri!.totalRecords.toString());
    return randTri;
  }

  Future<TotalTitleSearchTri?> fetchDataTriSplit(
      int opt, String start, String end) async {
    randTri = await RemoteServiceTri91SearchTotalSplit()
        .getBookTri91(start, end, widget.title, tSecretAPIKey);
    updateData(opt, randTri!.totalRecords.toString());
    updateResults(listResultsDetail, randTri!.detailRecords.toString());
    return randTri;
  }

  Widget titleByMode(String text, bool isM) {
    return isM ? ATextTitleMedium18(text: text) : ATextTitleLarge(text: text);
  }

  Widget triSection({
    required BuildContext context,
    required bool isM,
    required int indexShow,
    required String from,
    required String to,
    required String label,
    required String nikayaName,
    required String wordSearch,
    required dynamic titleMenu,
    required ValueNotifier<int> totalCounter,
  }) {
    return FutureBuilder<TotalTitleSearchTri?>(
      future: fetchDataTriSplit(indexShow, from, to),
      builder: (context, snapshot) {
        /// ⏳ ระหว่างรอ API
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'กำลังโหลดข้อมูล...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        /// ❌ error → ไม่แสดง
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final total = snapshot.data?.totalRecords ?? 0;

        /// ❌ ไม่มีข้อมูล → ไม่แสดง
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
              child: Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: titleByMode(
              '$nikayaName พบจำนวน $total รายการ',
              isM,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchTabShow(
                    title: wordSearch,
                    result: titleMenu,
                    resultDetail: listResultsDetail,
                    indexShow: indexShow,
                    isM: isM,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String wordSearch = widget.title;
    vinayaTotal.value = 0;
    suttantaTotal.value = 0;
    abhidhammaTotal.value = 0;
    return Scaffold(
      appBar: AppBar(
          title: ATextDiskplayLarge(text: 'ผลการค้นหาคำว่า \'$wordSearch\'')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(2.5),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.bottomLeft,
                        child: FutureBuilder<TotalTitleSearch?>(
                          future: fetchDataTitle(),
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
                                    child: Text(
                                      total.toString(),
                                    ),
                                  ),
                                  title: widget.isM
                                      ? ATextTitleMedium18(
                                          text:
                                              'หัวข้อธรรมสำคัญ พบจำนวน $total รายการ')
                                      : ATextTitleLarge(
                                          text:
                                              'หัวข้อธรรมสำคัญ พบจำนวน $total รายการ'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchTabShow(
                                          title: wordSearch,
                                          result: titleMenu,
                                          resultDetail: listResultsDetail,
                                          indexShow: 0,
                                          isM: widget.isM,
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
                                    child: Text(
                                      total.toString(),
                                    ),
                                  ),
                                  title: widget.isM
                                      ? ATextTitleMedium18(
                                          text:
                                              'หัวข้อธรรมสำคัญ พบจำนวน $total รายการ',
                                        )
                                      : ATextTitleMedium(
                                          text:
                                              'หัวข้อธรรมสำคัญ พบจำนวน $total รายการ',
                                        ),
                                );
                              }
                            }
                          },
                        ),
                      ),
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
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 1,
                        from: '1',
                        to: '4',
                        label: 'เล่ม 1-4',
                        nikayaName: 'มหาวิภังค์',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: vinayaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 1,
                        from: '5',
                        to: '5',
                        label: 'เล่ม 5',
                        nikayaName: 'ภิกขุนีวิภังค์',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: vinayaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 1,
                        from: '6',
                        to: '7',
                        label: 'เล่ม 6-7',
                        nikayaName: 'มหาวรรค',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: vinayaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 1,
                        from: '8',
                        to: '9',
                        label: 'เล่ม 8-9',
                        nikayaName: 'จุลวรรค',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: vinayaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 1,
                        from: '10',
                        to: '10',
                        label: 'เล่ม 10',
                        nikayaName: 'ปริวาร',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: vinayaTotal,
                      ),
                      const Divider(),
                      ValueListenableBuilder<int>(
                        valueListenable: suttantaTotal,
                        builder: (context, total, _) {
                          return ListTile(
                            title: titleByMode(
                              total == 0
                                  ? '[ พระสุตตันตปิฎก จำนวน 0 รายการ ]'
                                  : '[ พระสุตตันตปิฎก ]',
                              widget.isM,
                            ),
                          );
                        },
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 2,
                        from: '11',
                        to: '16',
                        label: 'เล่ม 11-16',
                        nikayaName: 'ทีฆนิกาย',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: suttantaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 2,
                        from: '17',
                        to: '23',
                        label: 'เล่ม 17-23',
                        nikayaName: 'มัชฌิมนิกาย',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: suttantaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 2,
                        from: '24',
                        to: '31',
                        label: 'เล่ม 24-31',
                        nikayaName: 'สังยุตตนิกาย',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: suttantaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 2,
                        from: '32',
                        to: '38',
                        label: 'เล่ม 32-38',
                        nikayaName: 'อังคุตตรนิกาย',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: suttantaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 2,
                        from: '39',
                        to: '74',
                        label: 'เล่ม 39-74',
                        nikayaName: 'ขุททกนิกาย',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: suttantaTotal,
                      ),
                      const Divider(),
                      ValueListenableBuilder<int>(
                        valueListenable: abhidhammaTotal,
                        builder: (context, total, _) {
                          return ListTile(
                            title: titleByMode(
                              total == 0
                                  ? '[ พระอภิธรรมปิฎก จำนวน 0 รายการ ]'
                                  : '[ พระอภิธรรมปิฎก ]',
                              widget.isM,
                            ),
                          );
                        },
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 3,
                        from: '75',
                        to: '76',
                        label: 'เล่ม 75-76',
                        nikayaName: 'ธรรมสังคณี',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: abhidhammaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 3,
                        from: '77',
                        to: '78',
                        label: 'เล่ม 77-78',
                        nikayaName: 'วิภังค์',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: abhidhammaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 3,
                        from: '79',
                        to: '79',
                        label: 'เล่ม 79',
                        nikayaName: 'ธาตุกถา-บุคคลบัญญัติ',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: abhidhammaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 3,
                        from: '80',
                        to: '81',
                        label: 'เล่ม 80-81',
                        nikayaName: 'กถาวัตถุ',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: abhidhammaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 3,
                        from: '82',
                        to: '84',
                        label: 'เล่ม 82-84',
                        nikayaName: 'ยมก',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: abhidhammaTotal,
                      ),
                      triSection(
                        context: context,
                        isM: widget.isM,
                        indexShow: 3,
                        from: '85',
                        to: '91',
                        label: 'เล่ม 85-91',
                        nikayaName: 'ปัฏฐาน',
                        wordSearch: wordSearch,
                        titleMenu: titleMenu,
                        totalCounter: abhidhammaTotal,
                      ),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.bottomLeft,
                        child: FutureBuilder<TotalTitleSearch?>(
                          future: fetchDict(),
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
                                    child: Text(
                                      total.toString(),
                                    ),
                                  ),
                                  title: widget.isM
                                      ? ATextTitleMedium18(
                                          text:
                                              'พจนานุกรม ฉบับประมวลศัพท์ พบจำนวน $total รายการ')
                                      : ATextTitleLarge(
                                          text:
                                              'พจนานุกรม ฉบับประมวลศัพท์ พบจำนวน $total รายการ',
                                        ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchTabShow(
                                          title: wordSearch,
                                          result: titleMenu,
                                          resultDetail: listResultsDetail,
                                          indexShow: 4,
                                          isM: widget.isM,
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
                                    child: Text(
                                      total.toString(),
                                    ),
                                  ),
                                  title: widget.isM
                                      ? ATextTitleMedium18(
                                          text:
                                              'พจนานุกรม ฉบับประมวลศัพท์ พบจำนวน $total รายการ',
                                        )
                                      : ATextTitleMedium(
                                          text:
                                              'พจนานุกรม ฉบับประมวลศัพท์ พบจำนวน $total รายการ',
                                        ),
                                );
                              }
                            }
                          },
                        ),
                      ),
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
                                    child: Text(
                                      total.toString(),
                                    ),
                                  ),
                                  title: widget.isM
                                      ? ATextTitleMedium18(
                                          text:
                                              'พจนานุกรม ไทย-บาลี พบจำนวน $total รายการ')
                                      : ATextTitleLarge(
                                          text:
                                              'พจนานุกรม ไทย-บาลี พบจำนวน $total รายการ'),
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
                                    child: Text(
                                      total.toString(),
                                    ),
                                  ),
                                  title: widget.isM
                                      ? ATextTitleMedium18(
                                          text:
                                              'พจนานุกรม ไทย-บาลี พบจำนวน $total รายการ')
                                      : ATextTitleMedium(
                                          text:
                                              'พจนานุกรม ไทย-บาลี พบจำนวน $total รายการ'),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.bottomLeft,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[900],
                            foregroundColor: Colors.white,
                            child: const Text(
                              '1+',
                            ),
                          ),
                          title: widget.isM
                              ? const ATextTitleMedium18(
                                  text: 'ค้นหาจากคำใกล้เคียง จำนวน 1+ รายการ')
                              : const ATextTitleLarge(
                                  text: 'ค้นหาจากคำใกล้เคียง จำนวน 1+ รายการ'),
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
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(),
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
