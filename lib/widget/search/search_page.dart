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
  TotalTitleSearchTri? randTri1;
  TotalTitleSearchTri? randTri2;
  TotalTitleSearchTri? randTri3;
  List<String> titleMenu = ["0", "0", "0", "0", "0", "0"];
  final dbhelper = DatabaseHelper();
  Map<String, dynamic> jsonData = {"set1": {}, "set2": {}, "set3": {}};

  // ฟังก์ชันที่ใช้สำหรับอัปเดตข้อมูลในดัชนีที่ระบุ
  void updateData(int index, String newValue) {
    // ตรวจสอบว่าดัชนีที่ระบุอยู่ในช่วงของ List
    if (index >= 0 && index < titleMenu.length) {
      // ทำการอัปเดตข้อมูลเฉพาะดัชนีที่ระบุ
      titleMenu[index] = newValue;
      // ไม่ต้องใช้ setState ในกรณีนี้ เนื่องจากเราอัปเดตเฉพาะส่วนหนึ่งของ List
    }
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
    randTri1 = await fetchDataTri1();
    setState(() {}); // Update UI for data1
    randTri2 = await fetchDataTri2();
    setState(() {}); // Update UI for data2
    randTri3 = await fetchDataTri3();
    setState(() {}); // Update UI for data3
    randDict1 = await fetchDict();
    setState(() {});
  }

  Widget buildListTri(
      TotalTitleSearchTri? data, String titleTri, int indexShow) {
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchTabShow(
                        title: widget.title,
                        result: titleMenu,
                        indexShow: indexShow,
                        isM: widget.isM,
                        online: widget.online,
                        volumeHelper: widget.volumeHelper),
                  ),
                );
              }
            : null,
      ),
    );
  }

  Widget buildListTitle(
      TotalTitleSearch? data, String titleTri, int indexShow) {
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchTabShow(
                        title: widget.title,
                        result: titleMenu,
                        indexShow: indexShow,
                        isM: widget.isM,
                        online: widget.online,
                        volumeHelper: widget.volumeHelper),
                  ),
                );
              }
            : null, // ปิดการใช้งาน onTap ถ้าไม่มีข้อมูล
      ),
    );
  }

  Widget buildListDict(
      TotalTitleSearch? data, String titleDict, int indexShow) {
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
            ? ATextTitleMedium18(text: '$titleDict พบจำนวน $total รายการ')
            : ATextTitleLarge(text: '$titleDict พบจำนวน $total รายการ'),
        onTap: total > 0
            ? () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchTabShow(
                        title: widget.title,
                        result: titleMenu,
                        indexShow: indexShow,
                        isM: widget.isM,
                        online: widget.online,
                        volumeHelper: widget.volumeHelper),
                  ),
                );
              }
            : null,
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
    randTitle = widget.online
        ? await RemoteServiceTitleSearchTotal()
            .getTitle(widget.title, tSecretAPIKey)
        : await dbhelper.getTri91TitleSearchDB(
            widget.title.replaceAll(' ', '%'),
          );
    updateData(0, randTitle!.totalRecords.toString());
    return randTitle;
  }

  Future<TotalTitleSearch?> fetchDict() async {
    randDict = widget.online
        ? await RemoteServiceDictSearchTotal()
            .getTitle(widget.title, tSecretAPIKey)
        : await dbhelper.getTriDictSearchDB(
            widget.title.replaceAll(' ', '%'),
          );
    updateData(4, randDict!.totalRecords.toString());
    return randDict;
  }

  Future<TotalTitleSearch?> fetchDictbt() async {
    randDictbt = randDict = widget.online
        ? await RemoteServiceDictbtSearchTotal()
            .getTitle(widget.title, tSecretAPIKey)
        : await dbhelper.getTriDictBtSearchDB(
            widget.title.replaceAll(' ', '%'),
          );
    updateData(5, randDictbt!.totalRecords.toString());
    return randDictbt;
  }

  Future<TotalTitleSearchTri?> fetchDataTri1() async {
    randTri = widget.online
        ? await RemoteServiceTri91SearchTotal()
            .getBookTri91("1", "10", widget.title, tSecretAPIKey)
        : await dbhelper.getBooks91_1SearchCount(
            widget.title.replaceAll(' ', '%'),
          );

    updateData(1, randTri!.totalRecords.toString());
    return randTri;
  }

  Future<TotalTitleSearchTri?> fetchDataTri2() async {
    randTri = widget.online
        ? await RemoteServiceTri91SearchTotal()
            .getBookTri91("11", "74", widget.title, tSecretAPIKey)
        : await dbhelper.getBooks91_2SearchCount(
            widget.title.replaceAll(' ', '%'),
          );
    updateData(2, randTri!.totalRecords.toString());
    return randTri;
  }

  Future<TotalTitleSearchTri?> fetchDataTri3() async {
    randTri = widget.online
        ? await RemoteServiceTri91SearchTotal()
            .getBookTri91("75", "91", widget.title, tSecretAPIKey)
        : await dbhelper.getBooks91_3SearchCount(
            widget.title.replaceAll(' ', '%'),
          );
    updateData(3, randTri!.totalRecords.toString());
    return randTri;
  }

  @override
  Widget build(BuildContext context) {
    String wordSearch = widget.title;
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
                      buildListTitle(randTitle1, 'หัวข้อธรรมสำคัญ', 0),
                      const Divider(),
                      buildListTri(randTri1, 'พระวินัยปิฎก', 1),
                      const Divider(),
                      buildListTri(randTri2, 'พระสุตตันตปิฎก', 2),
                      const Divider(),
                      buildListTri(randTri3, 'พระอภิธรรมปิฎก', 3),
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
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchTabShow(
                                            title: wordSearch,
                                            result: titleMenu,
                                            indexShow: 5,
                                            isM: widget.isM,
                                            online: widget.online,
                                            volumeHelper: widget.volumeHelper),
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
                      if (widget.online || widget.volumeHelper)
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
                                    text:
                                        'ค้นหาจากคำใกล้เคียง จำนวน 1+ รายการ'),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchTabShow(
                                      title: wordSearch,
                                      result: titleMenu,
                                      indexShow: 6,
                                      isM: widget.isM,
                                      online: widget.online,
                                      volumeHelper: widget.volumeHelper),
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
