import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/providers/user_provider.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';

// หน้าจอสำหรับแอดมิน (levelAccess=='1') ตรวจสอบข้อโต้แย้งเรื่องการแก้ไขคำผิด
// คำถูกที่ถูกนำไปใช้แล้ว (booksuscess==1) แต่มีสมาชิกแจ้งว่าแก้ไม่ถูกต้อง
// โครงหน้าจอมิเรอร์ MyUserPage (show_userall.dart) — infinite scroll +
// ตัวกรอง + การ์ด/ลิสต์ + เมนู ⋮ สำหรับการกระทำ
class LogEditDisputePage extends StatefulWidget {
  const LogEditDisputePage({super.key});

  @override
  State<LogEditDisputePage> createState() => _LogEditDisputePageState();
}

class _LogEditDisputePageState extends State<LogEditDisputePage> {
  List<dynamic> dataDispute = [];
  int loadedRecords = 0;
  bool loading = false;
  int page = 1;
  late String opt = '0'; // '0' = รอตรวจสอบ, '1' = ตรวจสอบแล้ว
  bool _isListView = false;
  // false เมื่อหน้าล่าสุดที่โหลดว่างเปล่า/คืน success:false (เช่น "ไม่พบข้อมูล")
  // กันไม่ให้ scroll listener ยิง fetch ซ้ำไม่จบเมื่อข้อมูลหมดแล้วแต่
  // รายการที่โหลดมายังไม่เต็มจอ (maxScrollExtent ยังเป็น 0)
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchDataDispute();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !loading &&
        _hasMore) {
      _fetchDataDispute();
    }
  }

  void _changeFilter(String newOpt) {
    setState(() {
      opt = newOpt;
      dataDispute = [];
      loadedRecords = 0;
      page = 1;
      _hasMore = true;
    });
    _fetchDataDispute();
  }

  void _handleAddData() {
    setState(() {
      dataDispute = [];
      loadedRecords = 0;
      page = 1;
      _hasMore = true;
    });
    _fetchDataDispute();
  }

  Future<void> _fetchDataDispute() async {
    if (loading || !_hasMore) return;
    setState(() {
      loading = true;
    });

    final response = await http.post(
      Uri.parse(tURLshowLogEditDisputeWithAll),
      body: {
        'token': tSecretAPIKey,
        'page': page.toString(),
        'opt': opt,
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        List<dynamic> newData = jsonResponse['message'];
        setState(() {
          dataDispute.addAll(newData);
          loadedRecords = dataDispute.length;
          page++;
          loading = false;
          if (newData.length < 50) _hasMore = false;
        });
      } else {
        // "ไม่พบข้อมูล" จาก show_logedit_dispute_withall.php แปลว่าหน้านี้ไม่มี
        // ข้อมูลเหลือแล้ว ไม่ใช่ error ที่ควรลองใหม่ไปเรื่อยๆ
        setState(() {
          loading = false;
          _hasMore = false;
        });
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
      setState(() {
        loading = false;
      });
    }
  }

  void _showSnackbar(BuildContext context, String info) {
    final snackBar = SnackBar(
      content: Text(info),
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: const Text('คุณต้องการดำเนินการต่อ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(' ยืนยัน '),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchResolveDispute(
    String bookid,
    String bookpage,
    String bookline,
    String action,
  ) async {
    final username = context.read<UserProvider>().user?.username ?? 'guest';
    final response = await http.post(
      Uri.parse(tURLresolveLogEditDispute),
      body: {
        'token': tSecretAPIKey,
        'username': username,
        'bookid': bookid,
        'bookpage': bookpage,
        'bookline': bookline,
        'action': action,
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        _handleAddData();
        _showSnackbar(context, '${jsonResponse['message']}');
      } else {
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  Widget _buildFilterToggle(BuildContext context) {
    Widget buildButton(String value, String label) {
      final selected = opt == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ElevatedButton(
          onPressed: () => _changeFilter(value),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              selected ? TColors.buttonPrimary : adaptiveSurfaceColor(context),
            ),
            foregroundColor: WidgetStateProperty.all<Color>(
              selected ? Colors.white : adaptiveTextColor(context),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: adaptiveBorderColor(context)),
              ),
            ),
          ),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          buildButton('0', 'รอตรวจสอบ'),
          buildButton('1', 'ตรวจสอบแล้ว'),
        ],
      ),
    );
  }

  Widget _buildActions(dynamic record) {
    final bookid = '${record['tripitaka91_book']}';
    final bookpage = '${record['tripitaka91_page']}';
    final bookline = '${record['tripitaka91_line']}';

    if (opt != '0') return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _ActionChip(
          icon: Icons.undo,
          label: 'ย้อนกลับ',
          onPressed: () async {
            bool? confirm = await _showConfirmationDialog(
              context,
              'ย้อนกลับข้อมูลเป็นก่อนแก้ไข?',
            );
            if (confirm == true) {
              await _fetchResolveDispute(bookid, bookpage, bookline, 'revert');
            }
          },
        ),
        _ActionChip(
          icon: Icons.close,
          label: 'ปฏิเสธ',
          danger: true,
          onPressed: () async {
            bool? confirm = await _showConfirmationDialog(
              context,
              'ปฏิเสธข้อโต้แย้งนี้?',
            );
            if (confirm == true) {
              await _fetchResolveDispute(bookid, bookpage, bookline, 'reject');
            }
          },
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, dynamic record, int index) {
    final userTmp = '${record['users']}'.replaceAll(',', ', ');

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
          CircleAvatar(
            radius: 15,
            backgroundColor: TColors.buttonPrimary,
            foregroundColor: Colors.white,
            child: Text(
              '${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เล่ม ${record['tripitaka91_book']} หน้า ${record['tripitaka91_page']} บรรทัด ${record['tripitaka91_line']}',
                  style: TextStyle(
                    fontFamily: 'THSarabunNew',
                    fontSize: 18,
                    color: adaptiveTextColor(context).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ข้อความปัจจุบัน: ${record['current_book_detail'] ?? ''}',
                  style: TextStyle(
                    fontFamily: 'THSarabunNew',
                    fontSize: 20,
                    color: adaptiveTextColor(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'เหตุผลที่แจ้ง: ${record['comments'] ?? ''}',
                  style: TextStyle(
                    fontFamily: 'THSarabunNew',
                    fontSize: 18,
                    color: adaptiveTextColor(context).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'แจ้งโดย: $userTmp (${record['dispute_count']} ครั้ง)',
                  style: TextStyle(
                    fontSize: 13,
                    color: adaptiveTextColor(context).withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                _buildActions(record),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(BuildContext context, dynamic record, int index) {
    final bookid = '${record['tripitaka91_book']}';
    final bookpage = '${record['tripitaka91_page']}';
    final bookline = '${record['tripitaka91_line']}';

    return Container(
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
          CircleAvatar(
            radius: 13,
            backgroundColor: TColors.buttonPrimary,
            foregroundColor: Colors.white,
            child: Text('${index + 1}'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'เล่ม ${record['tripitaka91_book']} หน้า ${record['tripitaka91_page']} บรรทัด ${record['tripitaka91_line']} — ${record['comments'] ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: adaptiveTextColor(context)),
            ),
          ),
          if (opt == '0')
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: adaptiveTextColor(context).withValues(alpha: 0.6),
              ),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'revert',
                  child: ListTile(
                    leading: Icon(Icons.undo),
                    title: Text('ย้อนกลับ'),
                  ),
                ),
                PopupMenuItem(
                  value: 'reject',
                  child: ListTile(
                    leading: Icon(Icons.close),
                    title: Text('ปฏิเสธ'),
                  ),
                ),
              ],
              onSelected: (value) async {
                bool? confirm = await _showConfirmationDialog(
                  context,
                  value == 'revert'
                      ? 'ย้อนกลับข้อมูลเป็นก่อนแก้ไข?'
                      : 'ปฏิเสธข้อโต้แย้งนี้?',
                );
                if (confirm == true) {
                  await _fetchResolveDispute(bookid, bookpage, bookline, value);
                }
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adaptivePageColor(context),
      appBar: AppBar(
        title: const Text('ตรวจสอบข้อโต้แย้งการแก้ไข'),
        actions: [
          IconButton(
            icon: Icon(
              _isListView ? Icons.view_agenda_outlined : Icons.view_list,
            ),
            color: Colors.white,
            tooltip: _isListView ? 'แสดงแบบการ์ด' : 'แสดงแบบลิสต์',
            onPressed: () {
              setState(() => _isListView = !_isListView);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: _buildFilterToggle(context),
          ),
          Expanded(
            child: dataDispute.isEmpty
                ? Center(
                    child: Text(
                      loading ? 'กำลังโหลด...' : 'ไม่พบข้อมูล',
                      style: TextStyle(
                        color: adaptiveTextColor(
                          context,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: loadedRecords + (loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= loadedRecords) {
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
                      final record = dataDispute[index];
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

// ปุ่มการทำงานขนาดเล็กแบบ chip (เหมือนกับที่ใช้ใน show_userall.dart)
class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? TColors.error : TColors.buttonPrimary;
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
      onPressed: onPressed,
    );
  }
}
