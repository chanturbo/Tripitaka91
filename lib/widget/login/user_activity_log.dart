import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // นำเข้า package สำหรับจัดรูปแบบวันที่และเวลา

import 'package:tripitaka91/utils/constants/api_constants.dart';

class UserActivityLogPage extends StatefulWidget {
  const UserActivityLogPage({super.key});

  @override
  State<UserActivityLogPage> createState() => _UserActivityLogPageState();
}

class _UserActivityLogPageState extends State<UserActivityLogPage> {
  final int batchSize = 50; // จำนวนรายการต่อการโหลด
  int currentPage = 0; // ตัวแปรสำหรับติดตามหน้าปัจจุบัน
  List<Map<String, dynamic>> logs = []; // เก็บ log ทั้งหมด
  bool isLoading = false; // สถานะการโหลด
  bool hasMore = true; // ตัวแปรตรวจสอบว่ามีข้อมูลเพิ่มหรือไม่

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMoreLogs(); // โหลดข้อมูลชุดแรก
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        _fetchMoreLogs();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMoreLogs() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse(tURLgetLogUser),
      body: {
        'page': currentPage.toString(),
        'batchSize': batchSize.toString(),
      },
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> fetchedLogs =
          List<Map<String, dynamic>>.from(jsonDecode(response.body)['logs']);

      setState(() {
        currentPage++; // เพิ่มหน้าปัจจุบันเพื่อใช้ในการดึงข้อมูลชุดถัดไป
        logs.addAll(fetchedLogs);
        hasMore = fetchedLogs.length == batchSize;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      // จัดการข้อผิดพลาดการโหลด
    }
  }

  String formatToGMT7(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);

    dateTime = dateTime.add(const Duration(hours: 7));

    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Activity Logs")),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: logs.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == logs.length) {
            return const Center(child: CircularProgressIndicator());
          }

          var log = logs[index];
          String activity = log['activity'];
          String userEmail = log['user_email'];
          String gmt7Time = formatToGMT7(log['timestamp']);

          return ListTile(
            title: Text(activity),
            subtitle: Text("User: $userEmail Time: $gmt7Time"),
          );
        },
      ),
    );
  }
}
