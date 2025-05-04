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

  Future<TotalTitleSearchTri?> fetchDataTri2() async {
    randTri = await RemoteServiceTri91SearchTotal()
        .getBookTri91("11", "74", widget.title, tSecretAPIKey);
    updateData(2, randTri!.totalRecords.toString());
    return randTri;
  }

  Future<TotalTitleSearchTri?> fetchDataTri3() async {
    randTri = await RemoteServiceTri91SearchTotal()
        .getBookTri91("75", "91", widget.title, tSecretAPIKey);
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
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchTabShow(
                                          title: wordSearch,
                                          result: titleMenu,
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
                      Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.bottomLeft,
                        child: FutureBuilder<TotalTitleSearchTri?>(
                          future: fetchDataTri1(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // กำลังโหลดข้อมูล
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              // กรณีเกิดข้อผิดพลาด
                              return Text('Error: ${snapshot.error}');
                            } else {
                              TotalTitleSearchTri? totalTitleSearch =
                                  snapshot.data;
                              int total = totalTitleSearch!.totalRecords;

                              // String detail = totalTitleSearch.detailRecords;
                              // List<String> detailList = detail.split('|');
                              // List<String> modifiedList =
                              //     detailList.map((item) {
                              //   // ใช้ replaceAll เพื่อแทนที่คำ # ด้วย 'พบจำนวน'
                              //   return '[เล่ม ${item.replaceAll('#', ' จำนวน ')} รายการ]';
                              // }).toList();
                              // String result = modifiedList.join('\n');
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
                                              'พระวินัยปิฎก พบจำนวน $total รายการ',
                                        )
                                      : ATextTitleLarge(
                                          text:
                                              'พระวินัยปิฎก พบจำนวน $total รายการ',
                                        ),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchTabShow(
                                          title: wordSearch,
                                          result: titleMenu,
                                          indexShow: 1,
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
                                              'พระวินัยปิฎก พบจำนวน $total รายการ',
                                        )
                                      : ATextTitleMedium(
                                          text:
                                              'พระวินัยปิฎก พบจำนวน $total รายการ',
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
                        child: FutureBuilder<TotalTitleSearchTri?>(
                          future: fetchDataTri2(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // กำลังโหลดข้อมูล
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              // กรณีเกิดข้อผิดพลาด
                              return Text('Error: ${snapshot.error}');
                            } else {
                              TotalTitleSearchTri? totalTitleSearch =
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
                                              'พระสุตตันตปิฎก พบจำนวน $total รายการ',
                                        )
                                      : ATextTitleLarge(
                                          text:
                                              'พระสุตตันตปิฎก พบจำนวน $total รายการ',
                                        ),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchTabShow(
                                          title: wordSearch,
                                          result: titleMenu,
                                          indexShow: 2,
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
                                              'พระสุตตันตปิฎก พบจำนวน $total รายการ',
                                        )
                                      : ATextTitleMedium(
                                          text:
                                              'พระสุตตันตปิฎก พบจำนวน $total รายการ',
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
                        child: FutureBuilder<TotalTitleSearchTri?>(
                          future: fetchDataTri3(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // กำลังโหลดข้อมูล
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              // กรณีเกิดข้อผิดพลาด
                              return Text('Error: ${snapshot.error}');
                            } else {
                              TotalTitleSearchTri? totalTitleSearch =
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
                                              'พระอภิธรรมปิฎก พบจำนวน $total รายการ',
                                        )
                                      : ATextTitleLarge(
                                          text:
                                              'พระอภิธรรมปิฎก พบจำนวน $total รายการ',
                                        ),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchTabShow(
                                          title: wordSearch,
                                          result: titleMenu,
                                          indexShow: 3,
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
                                              'พระอภิธรรมปิฎก พบจำนวน $total รายการ',
                                        )
                                      : ATextTitleMedium(
                                          text:
                                              'พระอภิธรรมปิฎก พบจำนวน $total รายการ',
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
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchTabShow(
                                          title: wordSearch,
                                          result: titleMenu,
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
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchTabShow(
                                          title: wordSearch,
                                          result: titleMenu,
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchTabShow(
                                  title: wordSearch,
                                  result: titleMenu,
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
