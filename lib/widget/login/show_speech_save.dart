import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/volume_helper/volume_helper.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';

class ShowSpeechSave extends StatefulWidget {
  const ShowSpeechSave({super.key});

  @override
  State<ShowSpeechSave> createState() => _ShowSpeechSaveState();
}

class _ShowSpeechSaveState extends State<ShowSpeechSave> {
  List<dynamic> dataTitle = [];
  int loadedRecordsTitle = 0;
  bool loadingTitle = false;
  int pageTitle = 1;
  late TextTitleReplace textTitleReplace;
  final ScrollController _scrollControllerTitle = ScrollController();
  late String opt = '0';
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  List<dynamic> dataUser = [];
  List<dynamic> dataUserCurrect = [];

  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();
    _scrollControllerTitle.addListener(_scrollListener);
    _fetchDataSpeech();
  }

  @override
  void dispose() {
    audioPlayerManager.dispose();
    super.dispose();
  }

  void _handleAddData() {
    // ทำการ setState() เพื่ออัปเดตข้อมูลใหม่
    setState(() {
      dataTitle = [];
      loadedRecordsTitle = 0;
      loadingTitle = false;
      pageTitle = 1;
      _fetchDataSpeech();
    });
  }

  void _scrollListener() {
    if (_scrollControllerTitle.offset >=
            _scrollControllerTitle.position.maxScrollExtent &&
        !_scrollControllerTitle.position.outOfRange) {
      _fetchDataSpeech();
    }
  }

  Future<void> _fetchDataSpeech() async {
    if (!loadingTitle) {
      setState(() {
        loadingTitle = true;
      });

      Users? users = await getUsersList();
      String tmpUser = 'guest';
      if (users != null) {
        tmpUser = users.username;
      }
      final response = await http.post(
        Uri.parse(tURLshowlogSpeechWithAll),
        body: {
          'token': tSecretAPIKey,
          'username': tmpUser,
          'page': pageTitle.toString(),
          'opt': opt,
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

        if (jsonResponse['success'] == true) {
          List<dynamic> newData = jsonResponse['message'];
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
            loadingTitle = false;
          });
        }
      } else {
        // ignore: avoid_print
        print('HTTP Error: ${response.statusCode}');
      }
    }
  }

  Future<void> _fetchUpdateInsertDataSpeakConfirm(String words) async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }
    final response = await http.post(
      Uri.parse(tURLupdateSpeakConfirm),
      body: {
        'token': tSecretAPIKey,
        'username': tmpUser,
        'words': words,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        opt = '1';
        _handleAddData();
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'บันทึกข้อมูลเรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
        // print('HTTP Error: ${response.statusCode}');
        // print('${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  Future<void> _fetchSpeakConfirmSuscess(String words, String wordspeak) async {
    final response = await http.post(
      Uri.parse(tURLsuscessSpeakConfirm),
      body: {
        'token': tSecretAPIKey,
        'wordsearch': words,
        'book_speak': '{$words:$wordspeak}',
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        opt = '2';
        _handleAddData();
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'บันทึกการแก้ไขข้อมูลเรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
        // print('HTTP Error: ${response.statusCode}');
        // print('${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  Future<void> _fetchDataUser(String words) async {
    final response = await http.post(
      Uri.parse(tURLtitleUserInPageSpeak),
      body: {
        'token': tSecretAPIKey,
        'words': words,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        List<dynamic> newData = jsonResponse['message'];
        dataUser.clear();
        dataUser.addAll(newData);
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  void _showDialogUser(BuildContext context, String title, String words) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _fetchDataUser(words),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Data has been fetched, show the dialog
              return AlertDialog(
                title: Text(title),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataUser.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[900],
                              foregroundColor:
                                  const Color.fromARGB(255, 173, 137, 137),
                              child: ATextDiskplaySmall(text: '${index + 1}'),
                            ),
                            title: ATextTitleMedium(
                              text:
                                  '${dataUser[index]['first_nameid']}${dataUser[index]['firstName']}  ${dataUser[index]['lastName']}',
                            ),
                            subtitle: ATextLabelMedium(
                                text:
                                    'วันที่ยืนยัน ${dataUser[index]['tripitaka91_dateconfirm_local']}'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            } else {
              // Data is still being fetched, show loading indicator or whatever you want
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  Future<void> _fetchDataUserCorrect(String words) async {
    final response = await http.post(
      Uri.parse(tURLtitleUserInPageCorrectSpeak),
      body: {
        'token': tSecretAPIKey,
        'words': words,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        List<dynamic> newData = jsonResponse['message'];
        dataUserCurrect.clear();
        dataUserCurrect.addAll(newData);
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  void _showDialogUserCorrect(
      BuildContext context, String title, String words) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _fetchDataUserCorrect(words),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Data has been fetched, show the dialog
              return AlertDialog(
                title: Text(title),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataUserCurrect.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[900],
                              foregroundColor:
                                  const Color.fromARGB(255, 173, 137, 137),
                              child: ATextDiskplaySmall(text: '${index + 1}'),
                            ),
                            title: ATextTitleMedium(
                              text:
                                  '${dataUserCurrect[index]['first_nameid']}${dataUserCurrect[index]['firstName']}  ${dataUserCurrect[index]['lastName']}',
                            ),
                            subtitle: ATextLabelMedium(
                                text:
                                    'วันที่เพิ่มข้อมูล ${dataUserCurrect[index]['tripitaka91_dateadd_local']}'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            } else {
              // Data is still being fetched, show loading indicator or whatever you want
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  void _showSnackbar(BuildContext context, String info) {
    final snackBar = SnackBar(
      content: Text(info),
      duration: const Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    return Scaffold(
      body: NotificationListener(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _fetchDataSpeech();
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollControllerTitle,
          itemCount: loadedRecordsTitle + 1,
          itemBuilder: (context, index) {
            if (index == loadedRecordsTitle) {
              return loadingTitle
                  ? const Center(child: CircularProgressIndicator())
                  : loadedRecordsTitle == 0
                      ? Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    opt = '0';
                                    _handleAddData();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<
                                        Color>(opt ==
                                            '0'
                                        ? Colors.orange
                                        : Colors
                                            .white), // กำหนดสีพื้นหลังเป็นสีขาว
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            18.0), // กำหนดขนาดของเส้นขอบ
                                        side: const BorderSide(
                                            color: Colors
                                                .black), // กำหนดสีของเส้นขอบ
                                      ),
                                    ),
                                  ),
                                  child: ATextLabelMediumColor(
                                      color: opt == '0'
                                          ? Colors.white
                                          : Colors.grey,
                                      text: ' แสดงข้อมูลที่ยังไม่ยืนยัน '),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    opt = '1';
                                    _handleAddData();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<
                                        Color>(opt ==
                                            '1'
                                        ? Colors.orange
                                        : Colors
                                            .white), // กำหนดสีพื้นหลังเป็นสีขาว
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            18.0), // กำหนดขนาดของเส้นขอบ
                                        side: const BorderSide(
                                            color: Colors
                                                .black), // กำหนดสีของเส้นขอบ
                                      ),
                                    ),
                                  ),
                                  child: ATextLabelMediumColor(
                                      color: opt == '1'
                                          ? Colors.white
                                          : Colors.grey,
                                      text: ' แสดงข้อมูลที่ยืนยันแล้ว '),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    opt = '2';
                                    _handleAddData();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<
                                        Color>(opt ==
                                            '2'
                                        ? Colors.orange
                                        : Colors
                                            .white), // กำหนดสีพื้นหลังเป็นสีขาว
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            18.0), // กำหนดขนาดของเส้นขอบ
                                        side: const BorderSide(
                                            color: Colors
                                                .black), // กำหนดสีของเส้นขอบ
                                      ),
                                    ),
                                  ),
                                  child: ATextLabelMediumColor(
                                      color: opt == '2'
                                          ? Colors.white
                                          : Colors.grey,
                                      text: ' แสดงข้อมูลที่แก้ไขแล้ว '),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink();
            }
            String userTmp = dataTitle[index]['username'];
            return Column(
              children: [
                if (index == 0) const SizedBox(height: 10),
                if (index == 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          opt = '0';
                          _handleAddData();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              opt == '0'
                                  ? Colors.orange
                                  : Colors.white), // กำหนดสีพื้นหลังเป็นสีขาว
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  18.0), // กำหนดขนาดของเส้นขอบ
                              side: const BorderSide(
                                  color: Colors.black), // กำหนดสีของเส้นขอบ
                            ),
                          ),
                        ),
                        child: ATextLabelMediumColor(
                            color: opt == '0' ? Colors.white : Colors.grey,
                            text: ' แสดงข้อมูลที่ยังไม่ยืนยัน '),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          opt = '1';
                          _handleAddData();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              opt == '1'
                                  ? Colors.orange
                                  : Colors.white), // กำหนดสีพื้นหลังเป็นสีขาว
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  18.0), // กำหนดขนาดของเส้นขอบ
                              side: const BorderSide(
                                  color: Colors.black), // กำหนดสีของเส้นขอบ
                            ),
                          ),
                        ),
                        child: ATextLabelMediumColor(
                            color: opt == '1' ? Colors.white : Colors.grey,
                            text: ' แสดงข้อมูลที่ยืนยันแล้ว '),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          opt = '2';
                          _handleAddData();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              opt == '2'
                                  ? Colors.orange
                                  : Colors.white), // กำหนดสีพื้นหลังเป็นสีขาว
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  18.0), // กำหนดขนาดของเส้นขอบ
                              side: const BorderSide(
                                  color: Colors.black), // กำหนดสีของเส้นขอบ
                            ),
                          ),
                        ),
                        child: ATextLabelMediumColor(
                            color: opt == '2' ? Colors.white : Colors.grey,
                            text: ' แสดงข้อมูลที่แก้ไขแล้ว '),
                      ),
                    ],
                  ),
                if (index == 0) const SizedBox(height: 10),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: dataTitle[index]['speak_suscess'] == 1
                        ? Colors.green
                        : opt == '0'
                            ? Colors.grey
                            : Colors.blue[900],
                    foregroundColor: Colors.white,
                    child: ATextDiskplayMedium(text: '${index + 1}'),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'คำที่ระบบน่าจะอ่านผิด : ',
                              style: TextStyle(
                                  fontFamily: 'THSarabunNew',
                                  fontSize: 24,
                                  color: Colors.grey),
                            ),
                            TextSpan(
                              text: '${dataTitle[index]['words']}\n',
                              style: const TextStyle(
                                  fontFamily: 'THSarabunNew',
                                  fontSize: 24,
                                  color: Colors.red),
                            ),
                            const TextSpan(
                              text: 'คำอ่าน : ',
                              style: TextStyle(
                                  fontFamily: 'THSarabunNew',
                                  fontSize: 24,
                                  color: Colors.grey),
                            ),
                            TextSpan(
                              text: '${dataTitle[index]['words_speak']}',
                              style: const TextStyle(
                                  fontFamily: 'THSarabunNew',
                                  fontSize: 24,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      opt == '0'
                          ? Row(
                              children: [
                                VolumeHelper().showVolume
                                    ? InkWell(
                                        onTap: () async {
                                          LoadingDialog.show(context);
                                          String txtTitle =
                                              '${dataTitle[index]['words_speak']}';
                                          String namesave =
                                              '${dataTitle[index]['words']}'
                                                  .trim()
                                                  .replaceAll(
                                                      RegExp(r'\s+'), '');

                                          String filename = 'tmp-$namesave';
                                          await audioPlayerManager.playAudio(
                                              '4', filename, txtTitle);
                                          // ignore: use_build_context_synchronously
                                          LoadingDialog.hide(context);
                                        },
                                        child: Icon(
                                          Icons.volume_up,
                                          size: 20,
                                          color: Colors.blue[
                                              300], // Change color as needed
                                        ),
                                      )
                                    : const Text(''),
                                VolumeHelper().showVolume
                                    ? const SizedBox(width: 10)
                                    : const SizedBox.shrink(),
                                InkWell(
                                  onTap: () async {
                                    bool? confirm =
                                        await _showConfirmationDialog(context);
                                    if (confirm!) {
                                      // print('ยืนยันข้อมูล');
                                      // print('${dataTitle[index]['words']}');
                                      await _fetchUpdateInsertDataSpeakConfirm(
                                          '${dataTitle[index]['words']}');
                                    }
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: ClipPath(
                                      clipper: DoubleTriangleRectangleClipper(),
                                      child: Container(
                                        padding: const EdgeInsets.all(3.0),
                                        color: Colors.red,
                                        child: const ATextDiskplaySmall(
                                            text: 'ยืนยันข้อมูล'),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: () {
                                    _showDialogUser(
                                        context,
                                        'รายชื่อสมาชิกที่ยืนยันแล้ว',
                                        '${dataTitle[index]['words']}');
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: ClipPath(
                                      clipper: DoubleTriangleRectangleClipper(),
                                      child: Container(
                                        padding: const EdgeInsets.all(3.0),
                                        color: Colors.green,
                                        child: ATextDiskplaySmall(
                                            text:
                                                'สมาชิกได้ยืนยันแล้ว ${dataTitle[index]['words_comfirm']} ท่าน'),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : opt == '1'
                              ? Row(
                                  children: [
                                    VolumeHelper().showVolume
                                        ? InkWell(
                                            onTap: () async {
                                              LoadingDialog.show(context);
                                              String txtTitle =
                                                  '${dataTitle[index]['words_speak']}';
                                              String namesave =
                                                  '${dataTitle[index]['words']}'
                                                      .trim()
                                                      .replaceAll(
                                                          RegExp(r'\s+'), '');

                                              String filename = 'tmp-$namesave';
                                              await audioPlayerManager
                                                  .playAudio(
                                                      '4', filename, txtTitle);
                                              // ignore: use_build_context_synchronously
                                              LoadingDialog.hide(context);
                                            },
                                            child: Icon(
                                              Icons.volume_up,
                                              size: 20,
                                              color: Colors.blue[
                                                  300], // Change color as needed
                                            ),
                                          )
                                        : const Text(''),
                                    VolumeHelper().showVolume
                                        ? const SizedBox(width: 10)
                                        : const SizedBox.shrink(),
                                    InkWell(
                                      onTap: () {
                                        _showDialogUser(
                                            context,
                                            'รายชื่อสมาชิกที่ยืนยันแล้ว',
                                            '${dataTitle[index]['words']}');
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: ClipPath(
                                          clipper:
                                              DoubleTriangleRectangleClipper(),
                                          child: Container(
                                            padding: const EdgeInsets.all(3.0),
                                            color: Colors.green,
                                            child: ATextDiskplaySmall(
                                                text:
                                                    'สมาชิกที่ได้ยืนยันแล้ว ${dataTitle[index]['words_comfirm']} ท่าน'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    VolumeHelper().showVolume
                                        ? InkWell(
                                            onTap: () async {
                                              LoadingDialog.show(context);
                                              String txtTitle =
                                                  '${dataTitle[index]['words_speak']}';
                                              String namesave =
                                                  '${dataTitle[index]['words']}'
                                                      .trim()
                                                      .replaceAll(
                                                          RegExp(r'\s+'), '');

                                              String filename = 'tmp-$namesave';
                                              await audioPlayerManager
                                                  .playAudio(
                                                      '4', filename, txtTitle);
                                              // ignore: use_build_context_synchronously
                                              LoadingDialog.hide(context);
                                            },
                                            child: Icon(
                                              Icons.volume_up,
                                              size: 20,
                                              color: Colors.blue[
                                                  300], // Change color as needed
                                            ),
                                          )
                                        : const Text(''),
                                    VolumeHelper().showVolume
                                        ? const SizedBox(width: 10)
                                        : const SizedBox.shrink(),
                                    dataTitle[index]['speak_suscess'] == 1
                                        ? Align(
                                            alignment: Alignment.centerLeft,
                                            child: ClipPath(
                                              clipper:
                                                  DoubleTriangleRectangleClipper(),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                color: Colors.green,
                                                child: const ATextLabelMediumColor(
                                                    color: Colors.white,
                                                    text:
                                                        ' ข้อมูลถูกแก้ไขเรียบร้อยแล้ว '),
                                              ),
                                            ),
                                          )
                                        : dataTitle[index]['words_comfirm'] >=
                                                tSpeakNum
                                            ? InkWell(
                                                onTap: () async {
                                                  Users? users =
                                                      await getUsersList();
                                                  String tmpLevel = '2';
                                                  if (users != null) {
                                                    tmpLevel =
                                                        users.levelAccess;
                                                  }
                                                  if (tmpLevel == '1') {
                                                    bool? confirm =
                                                        // ignore: use_build_context_synchronously
                                                        await _showConfirmationDialog(
                                                            context);
                                                    if (confirm!) {
                                                      // ignore: use_build_context_synchronously
                                                      LoadingDialog.show(
                                                          context);
                                                      await _fetchSpeakConfirmSuscess(
                                                          '${dataTitle[index]['words']}',
                                                          '${dataTitle[index]['words_speak']}');
                                                      // ignore: use_build_context_synchronously
                                                      LoadingDialog.hide(
                                                          context);
                                                      // print(
                                                      //     'ยืนยันการยืนแก้ไขข้อมูล');
                                                      // print('${dataTitle[index]['words']}');
                                                    }
                                                  } else {
                                                    // ignore: use_build_context_synchronously
                                                    _showSnackbar(context,
                                                        'คุณยังไม่ได้รับสิทธิ์ยืนยันการแก้ไขข้อมูล');
                                                  }
                                                },
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: ClipPath(
                                                    clipper:
                                                        DoubleTriangleRectangleClipper(),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              3.0),
                                                      color: Colors.red,
                                                      child: const ATextDiskplaySmall(
                                                          text:
                                                              'ยืนยันการยืนแก้ไขข้อมูล'),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Align(
                                                alignment: Alignment.centerLeft,
                                                child: ClipPath(
                                                  clipper:
                                                      DoubleTriangleRectangleClipper(),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    color: Colors.yellow,
                                                    child: const ATextLabelMediumColor(
                                                        color: Colors.black,
                                                        text:
                                                            ' รอสมาชิกยืนยันครบ $tSpeakNum ท่าน '),
                                                  ),
                                                ),
                                              ),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        _showDialogUser(
                                            context,
                                            'รายชื่อสมาชิกที่ยืนยันแล้ว',
                                            '${dataTitle[index]['words']}');
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: ClipPath(
                                          clipper:
                                              DoubleTriangleRectangleClipper(),
                                          child: Container(
                                            padding: const EdgeInsets.all(3.0),
                                            color: Colors.green,
                                            child: ATextDiskplaySmall(
                                                text:
                                                    'สมาชิกที่ยืนยัน ${dataTitle[index]['words_comfirm']} ท่าน'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                      const Divider(),
                      ATextTitleSmallTHColor(
                          color: Colors.grey,
                          text: 'หมายเหตุ ${dataTitle[index]['comments']}'),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _showDialogUserCorrect(
                              context,
                              'รายชื่อสมาชิกที่แจ้งคำที่น่าจะอ่านผิด/คำที่น่าจะอ่านถูก',
                              '${dataTitle[index]['words']}');
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ClipPath(
                            clipper: DoubleTriangleRectangleClipper(),
                            child: Container(
                              padding: const EdgeInsets.all(3.0),
                              color: Colors.orange,
                              child: ATextDiskplaySmall(
                                  text: 'แจ้งโดย : $userTmp'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // audioPlayerManager.stop();
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => Tri91PageView(
                    //       triBookid:
                    //           textTitleReplace.getBookId(dataTitle[index]),
                    //       triPageid: int.parse(
                    //           textTitleReplace.getPageId(dataTitle[index])),
                    //       triBookline:
                    //           textTitleReplace.getLineId(dataTitle[index]),
                    //       chkSearch: widget.wordSearch,
                    //     ),
                    //   ),
                    // );
                  },
                ),
                const Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
