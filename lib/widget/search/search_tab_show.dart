import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
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
import 'package:tripitaka91/widget/search/search_show_tri91.dart';
import 'package:tripitaka91/widget/search/search_show_tri91_onpage.dart';

class SearchTabShow extends StatelessWidget {
  final String title;
  final List<String> result;
  final int indexShow;
  final bool isM;

  const SearchTabShow(
      {super.key,
      required this.title,
      required this.result,
      required this.indexShow,
      required this.isM});

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
              isM: isM,
            ),
            MyPageTabDetail(
              title: title,
              indexLocal: 1,
              result: result,
              isM: isM,
            ),
            MyPageTabDetail(
              title: title,
              indexLocal: 2,
              result: result,
              isM: isM,
            ),
            MyPageTabDetail(
              title: title,
              indexLocal: 3,
              result: result,
              isM: isM,
            ),
            MyPageTabDetail(
              title: title,
              indexLocal: 4,
              result: result,
              isM: isM,
            ),
            MyPageTabDetail(
              title: title,
              indexLocal: 5,
              result: result,
              isM: isM,
            ),
          ],
          result: result,
          isM: isM),
    );
  }
}

class MyTabPage extends StatelessWidget {
  final int indexShow;
  final String title;
  final List<MyPageTabDetail> pages;
  final List<String> result;
  final bool isM;

  const MyTabPage({
    super.key,
    required this.indexShow,
    required this.title,
    required this.pages,
    required this.result,
    required this.isM,
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
                        text: 'หัวข้อธรรมสำคัญ [ ${results[0]} ]')
                    : ATextDiskplaySmallBlack(
                        text: 'หัวข้อธรรมสำคัญ [ ${results[0]} ]'),
              ),
              Tab(
                child: isM
                    ? ATextDiskplayLargeBlack(
                        text: 'พระวินัยปิฎก [ ${results[1]} ]')
                    : ATextDiskplaySmallBlack(
                        text: 'พระวินัยปิฎก [ ${results[1]} ]'),
              ),
              Tab(
                child: isM
                    ? ATextDiskplayLargeBlack(
                        text: 'พระสุตันตปิฎก [ ${results[2]} ]')
                    : ATextDiskplaySmallBlack(
                        text: 'พระสุตันตปิฎก [ ${results[2]} ]'),
              ),
              Tab(
                child: isM
                    ? ATextDiskplayLargeBlack(
                        text: 'พระอภิธรรมปิฎก [ ${results[3]} ]')
                    : ATextDiskplaySmallBlack(
                        text: 'พระอภิธรรมปิฎก [ ${results[3]} ]'),
              ),
              Tab(
                child: isM
                    ? ATextDiskplayLargeBlack(
                        text: 'ประมวลศัพท์ [ ${results[4]} ]')
                    : ATextDiskplaySmallBlack(
                        text: 'ประมวลศัพท์ [ ${results[4]} ]'),
              ),
              Tab(
                child: isM
                    ? ATextDiskplayLargeBlack(
                        text: 'พจนานุกรมไทย-บาลี [ ${results[5]} ]')
                    : ATextDiskplaySmallBlack(
                        text: 'พจนานุกรมไทย-บาลี [ ${results[5]} ]'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: pages.map((page) => page).toList(),
        ),
      ),
    );
  }
}

class MyPageTabDetail extends StatefulWidget {
  final String title;
  final int indexLocal;
  final List<String> result;
  final bool isM;
  const MyPageTabDetail({
    super.key,
    required this.title,
    required this.indexLocal,
    required this.result,
    required this.isM,
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

  @override
  void initState() {
    super.initState();
    indexlocal = widget.indexLocal;
    if (indexlocal == 0) {
      // fetchDataTitle = loadDataTitle();
    } else if (indexlocal == 1) {
      loadDataTri1();
    } else if (indexlocal == 2) {
      loadDataTri2();
    } else if (indexlocal == 3) {
      loadDataTri3();
    } else if (indexlocal == 4) {
      fetchDict();
    } else if (indexlocal == 5) {
      fetchDictbt();
      // fetchData = loadData();
    }
  }

  Future<String> loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    // ประมวลผลข้อมูลจาก searchQuery และ title ตามความต้องการ
    return "Data loaded for and ${widget.title}";
  }

  Future<List<RandTitle?>> loadDataTitle() async {
    randTitle = (await RemoteServiceTitleSearch()
        .getTitle(widget.title, tSecretAPIKey))!;
    return randTitle;
  }

  Future<TotalTitleSearchTri?> loadDataTri1() async {
    randTri = await RemoteServiceTri91SearchTotal()
        .getBookTri91("1", "10", widget.title, tSecretAPIKey);
    return randTri;
  }

  Future<TotalTitleSearchTri?> loadDataTri2() async {
    randTri = await RemoteServiceTri91SearchTotal()
        .getBookTri91("11", "74", widget.title, tSecretAPIKey);
    return randTri;
  }

  Future<TotalTitleSearchTri?> loadDataTri3() async {
    randTri = await RemoteServiceTri91SearchTotal()
        .getBookTri91("75", "91", widget.title, tSecretAPIKey);
    return randTri;
  }

  Future<TotalTitleSearch?> fetchDict() async {
    randDict = await RemoteServiceDictSearchTotal()
        .getTitle(widget.title, tSecretAPIKey);
    return randDict;
  }

  Future<TotalTitleSearch?> fetchDictbt() async {
    randDict = await RemoteServiceDictbtSearchTotal()
        .getTitle(widget.title, tSecretAPIKey);

    return randDict;
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
          border: Border.all(
            color: Colors.blue,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(2.5),
        child: indexlocal == 0
            ? widget.result[0] == '0'
                ? const Text('ไม่พบข้อมูลสำหรับแสดงผล')
                : SearchShowPagesTitle(
                    wordSearch: wordSearch,
                    isM: widget.isM,
                  )
            : indexlocal == 1
                ? FutureBuilder<TotalTitleSearchTri?>(
                    future: loadDataTri1(),
                    builder: (context, snapshot) {
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
                          List<Map<String, dynamic>> dataList = [];
                          List<String> pairs = detail.split('|');
                          for (var pair in pairs) {
                            List<String> keyValue = pair.split('#');
                            if (keyValue.length == 2) {
                              String book = keyValue[0];
                              String page = keyValue[1];
                              Map<String, dynamic> data = {
                                'book': book,
                                'page': page,
                              };
                              if (bookSearchid1 == '0') {
                                bookSearchid1 = book;
                              }
                              dataList.add(data);
                            }
                          }
                          return widget.isM
                              ? ListView.builder(
                                  itemCount: dataList.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> data = dataList[index];
                                    String strBook = data['book'];
                                    String strTotal =
                                        'เล่ม $strBook พบจำนวน ${data['page']} รายการ';
                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.blue[900],
                                            foregroundColor: Colors.white,
                                            child: Text(strBook),
                                          ),
                                          title: SubstringHighlight(
                                            text: strTotal,
                                            terms:
                                                outputList, // หาก outputList ยังไม่ได้ถูกกำหนดให้ใช้ตามความเหมาะสม
                                            textStyle: TextStyle(
                                                fontSize:
                                                    widget.isM ? 18.0 : 16.0,
                                                color: Colors.black),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchShowPages(
                                                  title: strTotal,
                                                  wordSearch: widget.title,
                                                  bookid: strBook,
                                                  isM: widget.isM,
                                                  catalog: 'พระวินัยปิฎก',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const Divider(),
                                      ],
                                    );
                                  },
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: ListView.builder(
                                        itemCount: dataList.length,
                                        itemBuilder: (context, index) {
                                          Map<String, dynamic> data =
                                              dataList[index];
                                          String strBook = data['book'];
                                          String strTotal =
                                              'เล่ม $strBook พบจำนวน ${data['page']} รายการ';
                                          return Column(
                                            children: [
                                              ListTile(
                                                leading: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.blue[900],
                                                  foregroundColor: Colors.white,
                                                  child: Text(strBook),
                                                ),
                                                title: SubstringHighlight(
                                                  text: strTotal,
                                                  terms:
                                                      outputList, // หาก outputList ยังไม่ได้ถูกกำหนดให้ใช้ตามความเหมาะสม
                                                  textStyle: TextStyle(
                                                      fontSize: widget.isM
                                                          ? 18.0
                                                          : 16.0,
                                                      color: Colors.black),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    bookSearchid1 = strBook;
                                                  });
                                                },
                                              ),
                                              const Divider(),
                                            ],
                                          );
                                        },
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
                                      flex: 3,
                                      child: SearchShowPagesOnPage(
                                        title: '',
                                        wordSearch: widget.title,
                                        bookid: bookSearchid1,
                                        isM: widget.isM,
                                        catalog: 'พระวินัยปิฎก',
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // กำลังโหลดข้อมูล
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            // กรณีเกิดข้อผิดพลาด
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            TotalTitleSearchTri? totalTitleSearch =
                                snapshot.data;
                            if (totalTitleSearch?.totalRecords != 0) {
                              String detail = totalTitleSearch!.detailRecords;
                              List<Map<String, dynamic>> dataList = [];
                              List<String> pairs = detail.split('|');
                              for (var pair in pairs) {
                                List<String> keyValue = pair.split('#');
                                if (keyValue.length == 2) {
                                  String book = keyValue[0];
                                  String page = keyValue[1];
                                  Map<String, dynamic> data = {
                                    'book': book,
                                    'page': page,
                                  };
                                  if (bookSearchid2 == '0') {
                                    bookSearchid2 = book;
                                  }
                                  dataList.add(data);
                                }
                              }
                              return widget.isM
                                  ? ListView.builder(
                                      itemCount: dataList.length,
                                      itemBuilder: (context, index) {
                                        Map<String, dynamic> data =
                                            dataList[index];
                                        String strBook = data['book'];
                                        String strTotal =
                                            'เล่ม $strBook พบจำนวน ${data['page']} รายการ';
                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    Colors.blue[900],
                                                foregroundColor: Colors.white,
                                                child: Text(strBook),
                                              ),
                                              title: SubstringHighlight(
                                                text: strTotal,
                                                terms:
                                                    outputList, // หาก outputList ยังไม่ได้ถูกกำหนดให้ใช้ตามความเหมาะสม
                                                textStyle: TextStyle(
                                                    fontSize: widget.isM
                                                        ? 18.0
                                                        : 16.0,
                                                    color: Colors.black),
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SearchShowPages(
                                                      title: strTotal,
                                                      wordSearch: widget.title,
                                                      bookid: strBook,
                                                      isM: widget.isM,
                                                      catalog: 'พระสุตตันตปิฎก',
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const Divider(),
                                          ],
                                        );
                                      },
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: ListView.builder(
                                            itemCount: dataList.length,
                                            itemBuilder: (context, index) {
                                              Map<String, dynamic> data =
                                                  dataList[index];
                                              String strBook = data['book'];
                                              String strTotal =
                                                  'เล่ม $strBook พบจำนวน ${data['page']} รายการ';
                                              return Column(
                                                children: [
                                                  ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.blue[900],
                                                      foregroundColor:
                                                          Colors.white,
                                                      child: Text(strBook),
                                                    ),
                                                    title: SubstringHighlight(
                                                      text: strTotal,
                                                      terms:
                                                          outputList, // หาก outputList ยังไม่ได้ถูกกำหนดให้ใช้ตามความเหมาะสม
                                                      textStyle: TextStyle(
                                                          fontSize: widget.isM
                                                              ? 18.0
                                                              : 16.0,
                                                          color: Colors.black),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        bookSearchid2 = strBook;
                                                      });
                                                    },
                                                  ),
                                                  const Divider(),
                                                ],
                                              );
                                            },
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
                                          flex: 3,
                                          child: SearchShowPagesOnPage(
                                            title: '',
                                            wordSearch: widget.title,
                                            bookid: bookSearchid2,
                                            isM: widget.isM,
                                            catalog: 'พระสุตตันตปิฎก',
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
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // กำลังโหลดข้อมูล
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                // กรณีเกิดข้อผิดพลาด
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData) {
                                TotalTitleSearchTri? totalTitleSearch =
                                    snapshot.data;
                                if (totalTitleSearch?.totalRecords != 0) {
                                  String detail =
                                      totalTitleSearch!.detailRecords;
                                  List<Map<String, dynamic>> dataList = [];
                                  List<String> pairs = detail.split('|');
                                  for (var pair in pairs) {
                                    List<String> keyValue = pair.split('#');
                                    if (keyValue.length == 2) {
                                      String book = keyValue[0];
                                      String page = keyValue[1];
                                      Map<String, dynamic> data = {
                                        'book': book,
                                        'page': page,
                                      };
                                      if (bookSearchid3 == '0') {
                                        bookSearchid3 = book;
                                      }
                                      dataList.add(data);
                                    }
                                  }
                                  return widget.isM
                                      ? ListView.builder(
                                          itemCount: dataList.length,
                                          itemBuilder: (context, index) {
                                            Map<String, dynamic> data =
                                                dataList[index];
                                            String strBook = data['book'];
                                            String strTotal =
                                                'เล่ม $strBook พบจำนวน ${data['page']} รายการ';
                                            return Column(
                                              children: [
                                                ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.blue[900],
                                                    foregroundColor:
                                                        Colors.white,
                                                    child: Text(strBook),
                                                  ),
                                                  title: SubstringHighlight(
                                                    text: strTotal,
                                                    terms:
                                                        outputList, // หาก outputList ยังไม่ได้ถูกกำหนดให้ใช้ตามความเหมาะสม
                                                    textStyle: TextStyle(
                                                        fontSize: widget.isM
                                                            ? 18.0
                                                            : 16.0,
                                                        color: Colors.black),
                                                  ),
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
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                const Divider(),
                                              ],
                                            );
                                          },
                                        )
                                      : Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: ListView.builder(
                                                itemCount: dataList.length,
                                                itemBuilder: (context, index) {
                                                  Map<String, dynamic> data =
                                                      dataList[index];
                                                  String strBook = data['book'];
                                                  String strTotal =
                                                      'เล่ม $strBook พบจำนวน ${data['page']} รายการ';
                                                  return Column(
                                                    children: [
                                                      ListTile(
                                                        leading: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.blue[900],
                                                          foregroundColor:
                                                              Colors.white,
                                                          child: Text(strBook),
                                                        ),
                                                        title:
                                                            SubstringHighlight(
                                                          text: strTotal,
                                                          terms:
                                                              outputList, // หาก outputList ยังไม่ได้ถูกกำหนดให้ใช้ตามความเหมาะสม
                                                          textStyle: TextStyle(
                                                              fontSize:
                                                                  widget.isM
                                                                      ? 18.0
                                                                      : 16.0,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            bookSearchid3 =
                                                                strBook;
                                                          });
                                                        },
                                                      ),
                                                      const Divider(),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.topCenter,
                                              child: CustomPaint(
                                                painter:
                                                    MyVerticalLinePainter(),
                                                size: Size(0.5, screenHeight),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: SearchShowPagesOnPage(
                                                title: '',
                                                wordSearch: widget.title,
                                                bookid: bookSearchid3,
                                                isM: widget.isM,
                                                catalog: 'พระอภิธรรมปิฎก',
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
                                  )
                            : indexlocal == 5
                                ? widget.result[5] == '0'
                                    ? const Text('ไม่พบข้อมูลสำหรับแสดงผล')
                                    : SearchShowPagesDictbt(
                                        wordSearch: wordSearch,
                                        isM: widget.isM,
                                      )
                                : FutureBuilder(
                                    future: fetchData,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        return Center(
                                          child: Text(snapshot.data.toString()),
                                        );
                                      }
                                    },
                                  ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
