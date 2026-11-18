import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/auto_text/text_span.dart';

class LogEditScreen extends StatefulWidget {
  const LogEditScreen({super.key});

  @override
  State<LogEditScreen> createState() => _LogEditScreenState();
}

class _LogEditScreenState extends State<LogEditScreen> {
  List<dynamic> dataTitle = [];
  int loadedRecordsTitle = 0;
  bool loadingTitle = false;
  int pageTitle = 1;
  bool _isListView = false;
  final ScrollController _scrollControllerTitle = ScrollController();
  int? _selectedBook; // ประกาศตัวแปรเพื่อเก็บเลขเล่มที่ถูกเลือก

  @override
  void initState() {
    super.initState();
    _scrollControllerTitle.addListener(_scrollListener);
    _fetchDataLogedit();
  }

  @override
  void dispose() {
    _scrollControllerTitle.removeListener(_scrollListener);
    _scrollControllerTitle.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollControllerTitle.offset >=
            _scrollControllerTitle.position.maxScrollExtent &&
        !loadingTitle) {
      _fetchDataLogedit();
    }
  }

  // รีเฟรชข้อมูลทั้งหมดใหม่ตั้งแต่หน้า 1 (ใช้หลังเปลี่ยนเล่มที่กรอง)
  void _handleAddData() {
    setState(() {
      dataTitle = [];
      loadedRecordsTitle = 0;
      pageTitle = 1;
    });
    _fetchDataLogedit();
  }

  Future<void> _fetchDataLogedit() async {
    if (!loadingTitle) {
      setState(() {
        loadingTitle = true;
      });

      Users? users = await getUsersList();
      String tmpUser = 'guest';
      if (users != null) {
        tmpUser = users.username;
      }
      String selectdBook = '0';
      if (_selectedBook != null) {
        selectdBook = _selectedBook.toString();
      }
      final response = await http.post(
        Uri.parse(tURLshowlogEditWithUser),
        body: {
          'token': tSecretAPIKey,
          'username': tmpUser,
          'book': selectdBook,
          'page': pageTitle.toString(),
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(json);

        if (jsonResponse['success'] == true) {
          List<dynamic> newData = jsonResponse['message'];
          setState(() {
            dataTitle.addAll(newData);
            loadedRecordsTitle = dataTitle.length;
            pageTitle++;
            loadingTitle = false;
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
        setState(() {
          loadingTitle = false;
        });
      }
    }
  }

  void _showSnackbar(BuildContext context, String info) {
    final snackBar = SnackBar(
      content: Text(info),
      duration: const Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // ชิปสถานะแบบย่อ ใช้แทน ClipPath สามเหลี่ยมคู่แบบเดิม (คงรูปแบบเดียวกับ
  // รายการแจ้งการอ่านออกเสียง/ยืนยันการแก้ไขการอ่านออกเสียง)
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // คืนชิปสถานะของรายการนี้ หรือ null หากยังไม่มีสถานะใดๆ จะแสดง
  Widget? _buildStatusTag(dynamic record) {
    if (record['book_suscess'] == 1) {
      return _buildTag('ข้อมูลถูกแก้ไขเรียบร้อยแล้ว', TColors.success);
    } else if (record['book_confirm'] > 0) {
      return _buildTag('อยู่ในกระบวนการแก้ไขข้อมูล', TColors.warning);
    }
    return null;
  }

  Widget _buildIndexBadge(dynamic record, int index, {double radius = 15}) {
    final color = record['book_suscess'] == 1
        ? TColors.success
        : record['book_confirm'] > 0
        ? TColors.buttonPrimary
        : Colors.grey;
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      foregroundColor: Colors.white,
      child: Text(
        '${index + 1}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailBody(BuildContext context, dynamic record) {
    final statusTag = _buildStatusTag(record);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เล่ม ${record['tripitaka91_book']} หน้า ${record['tripitaka91_page']} บรรทัด ${record['tripitaka91_line']}',
          style: TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 18,
            color: adaptiveTextColor(context).withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'คำที่น่าจะผิด: ',
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 20,
                  color: adaptiveTextColor(context).withValues(alpha: 0.6),
                ),
              ),
              TextSpan(
                text: '${record['tripitaka91_wordincorrect']}',
                style: const TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 20,
                  color: TColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'คำที่น่าจะถูก: ',
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 20,
                  color: adaptiveTextColor(context).withValues(alpha: 0.6),
                ),
              ),
              TextSpan(
                text: '${record['tripitaka91_wordcorrect']}',
                style: const TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 20,
                  color: TColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'ข้อความเต็ม: ',
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 18,
                  color: adaptiveTextColor(context).withValues(alpha: 0.6),
                ),
              ),
              txtSpanHighlight(
                ('${record['tripitaka91_wordincorrect']}').split(','),
                '${record['book_detail_old']}',
              ),
            ],
          ),
        ),
        if (statusTag != null) ...[const SizedBox(height: 8), statusTag],
      ],
    );
  }

  void _showDetailDialog(BuildContext context, dynamic record, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              _buildIndexBadge(record, index, radius: 14),
              const SizedBox(width: 10),
              const Text('รายละเอียด'),
            ],
          ),
          content: SingleChildScrollView(
            child: _buildDetailBody(context, record),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, dynamic record, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: adaptiveSurfaceColor(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIndexBadge(record, index),
          const SizedBox(width: 12),
          Expanded(child: _buildDetailBody(context, record)),
        ],
      ),
    );
  }

  // แถวแบบย่อ (โหมดลิสต์): บรรทัดเดียวต่อรายการ แตะเพื่อดูรายละเอียดเต็ม
  Widget _buildListRow(BuildContext context, dynamic record, int index) {
    final statusTag = _buildStatusTag(record);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _showDetailDialog(context, record, index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: adaptiveSurfaceColor(context),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildIndexBadge(record, index, radius: 13),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${record['tripitaka91_wordincorrect']}',
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColors.error,
                      ),
                    ),
                    TextSpan(
                      text: '  →  ',
                      style: TextStyle(
                        fontSize: 14,
                        color: adaptiveTextColor(
                          context,
                        ).withValues(alpha: 0.4),
                      ),
                    ),
                    TextSpan(
                      text: '${record['tripitaka91_wordcorrect']}',
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (statusTag != null) ...[const SizedBox(width: 6), statusTag],
            const SizedBox(width: 4),
            Icon(
              Icons.info_outline,
              size: 18,
              color: adaptiveTextColor(context).withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: adaptivePageColor(context),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: adaptiveBorderColor(context)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        isExpanded: true,
                        value: _selectedBook,
                        hint: const Text('เลือกเล่มหนังสือ'),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: 0,
                            child: Text('เล่มทั้งหมด'),
                          ),
                          ...List.generate(91, (index) {
                            int bookNumber = index + 1;
                            return DropdownMenuItem<int?>(
                              value: bookNumber,
                              child: Text('เล่มที่ $bookNumber'),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedBook = value;
                          });
                          _handleAddData();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isListView ? Icons.view_agenda_outlined : Icons.view_list,
                  ),
                  tooltip: _isListView ? 'แสดงแบบการ์ด' : 'แสดงแบบลิสต์',
                  onPressed: () {
                    setState(() => _isListView = !_isListView);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: dataTitle.isEmpty
                ? Center(
                    child: Text(
                      loadingTitle ? 'กำลังโหลด...' : 'ไม่พบข้อมูล',
                      style: TextStyle(
                        color: adaptiveTextColor(
                          context,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollControllerTitle,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: loadedRecordsTitle + (loadingTitle ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= loadedRecordsTitle) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        );
                      }
                      final record = dataTitle[index];
                      return _isListView
                          ? _buildListRow(context, record, index)
                          : _buildCard(context, record, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
