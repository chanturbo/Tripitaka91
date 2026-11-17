import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/common/circular_icon_button.dart';
import 'package:tripitaka91/widget/common/index_badge.dart';
import 'package:tripitaka91/widget/login/profile_user.dart';

class MyUserPage extends StatefulWidget {
  final String filterType;
  final String totalMember;
  const MyUserPage({
    super.key,
    required this.filterType,
    required this.totalMember,
  });

  @override
  State<MyUserPage> createState() => _MyUserPageState();
}

class _MyUserPageState extends State<MyUserPage> {
  List<dynamic> dataTitle = [];
  int loadedRecordsTitle = 0;
  bool loadingTitle = false;
  int pageTitle = 1;
  late TextTitleReplace textTitleReplace;
  final ScrollController _scrollControllerTitle = ScrollController();
  late String opt = '0';
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  String _filterType = 'ชื่อทั้งหมด'; // ตัวเลือกการกรองเริ่มต้น
  // ignore: unused_field
  String _searchText = ''; // ข้อความที่ใช้กรอกค้นหา
  final TextEditingController _controlSearchText = TextEditingController();
  String tmpUser = '';
  bool _isListView = false; // false = การ์ด (ค่าเริ่มต้น), true = ลิสต์แบบย่อ

  @override
  void initState() {
    super.initState();
    _filterType = widget.filterType;
    textTitleReplace = TextTitleReplace();
    _scrollControllerTitle.addListener(_scrollListener);
    _fetchDataUser(_filterType, _searchText);
  }

  @override
  void dispose() {
    audioPlayerManager.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollControllerTitle.offset >=
            _scrollControllerTitle.position.maxScrollExtent &&
        !_scrollControllerTitle.position.outOfRange) {
      _fetchDataUser(_filterType, _searchText);
    }
  }

  void _handleAddData() {
    setState(() {
      dataTitle = [];
      loadedRecordsTitle = 0;
      loadingTitle = false;
      pageTitle = 1;
      _fetchDataUser(_filterType, _searchText);
    });
  }

  Future<void> _fetchDataUser(String? filter, String? searchText) async {
    if (!loadingTitle) {
      setState(() {
        loadingTitle = true;
      });

      tmpUser = (await getUsersList())?.username ?? 'guest';

      final response = await http.post(
        Uri.parse(tURLshowUser),
        body: {
          'token': tSecretAPIKey,
          'page': pageTitle.toString(),
          'filter': filter,
          'searchText': ?searchText,
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(json);

        if (jsonResponse['success'] == true) {
          List<dynamic> newData = jsonResponse['users'];
          setState(() {
            loadedRecordsTitle += newData.length;
            dataTitle.addAll(newData);
            loadingTitle = false;
            pageTitle++;
          });
        } else {
          // print(jsonResponse['message']);
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
                Navigator.of(
                  context,
                ).pop(false); // ปิดหน้าต่างและส่งค่า false กลับ
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(true); // ปิดหน้าต่างและส่งค่า true กลับ
              },
              child: const Text(' ยืนยัน '),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchConfirmVoice(String user, String level) async {
    try {
      final response = await http.post(
        Uri.parse(tURLconfirmVoice),
        body: {
          'token': tSecretAPIKey,
          'email': user,
          'level': level, // เพิ่มการส่งค่า level (opt)
          'email_process': tmpUser,
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(json);

        if (jsonResponse['success'] == true) {
          _handleAddData();
          // ignore: use_build_context_synchronously
          _showSnackbar(context, 'กำหนดสิทธิ์ยืนยันเสียงอ่านเรียบร้อยแล้ว');
        } else {
          // ignore: use_build_context_synchronously
          _showSnackbar(context, '${jsonResponse['message']}');
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'เกิดข้อผิดพลาดใน HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error: $e');
      // ignore: use_build_context_synchronously
      _showSnackbar(context, 'เกิดข้อผิดพลาด: $e');
    }
  }

  Future<void> _fetchConfirmAdmin(String user, String level) async {
    try {
      final response = await http.post(
        Uri.parse(tURLconfirmAdmin),
        body: {
          'token': tSecretAPIKey,
          'email': user,
          'level': level, // เพิ่มการส่งค่า level (opt)
          'email_process': tmpUser,
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(json);

        if (jsonResponse['success'] == true) {
          _handleAddData();
          // ignore: use_build_context_synchronously
          _showSnackbar(context, 'ยืนยันการเป็น Admin $user เรียบร้อยแล้ว');
        } else {
          // ignore: use_build_context_synchronously
          _showSnackbar(context, '${jsonResponse['message']}');
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'เกิดข้อผิดพลาดใน HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error: $e');
      // ignore: use_build_context_synchronously
      _showSnackbar(context, 'เกิดข้อผิดพลาด: $e');
    }
  }

  Future<void> _fetchConfirmRegis(String user) async {
    final response = await http.post(
      Uri.parse(tURLconfirmUser),
      body: {'token': tSecretAPIKey, 'email': user},
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        _handleAddData();
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'ยืนยันการสมัครสมาชิก $user เรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  Future<void> _fetchResetPass(String user) async {
    final response = await http.post(
      Uri.parse(tURLresetUserPass),
      body: {'token': tSecretAPIKey, 'email': user, 'password': 'password'},
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        _handleAddData();
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'รีเซตรหัสผ่านของ $user เรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adaptivePageColor(context),
      appBar: AppBar(
        title: Text('ผู้ใช้งานทั้งหมด [${widget.totalMember} ราย]'),
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
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Dropdown สำหรับเลือกการกรอง
                DropdownButton<String>(
                  value: _filterType,
                  underline: const SizedBox(),
                  items:
                      <String>[
                        'ชื่อทั้งหมด',
                        'Admin',
                        'รอการยืนยัน',
                        'ผู้มีสิทธิ์ยืนยันเสียงอ่าน',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text('แสดง $value'),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _filterType = newValue!;
                      _searchText = '';
                      _controlSearchText.clear;
                      _handleAddData();
                    });
                  },
                ),
                const SizedBox(width: 10),
                // TextField สำหรับกรอกข้อมูลค้นหา
                Expanded(
                  child: TextField(
                    controller: _controlSearchText,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'ค้นหาสมาชิก...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                        _handleAddData();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is ScrollEndNotification &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _fetchDataUser(_filterType, _searchText);
                }
                return false;
              },
              child: ListView.builder(
                controller: _scrollControllerTitle,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: loadedRecordsTitle + 1,
                itemBuilder: (context, index) {
                  if (index == loadedRecordsTitle) {
                    return loadingTitle
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink();
                  }
                  final user = dataTitle[index];
                  if (_isListView) {
                    return _buildListRow(context, user, index);
                  }
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
                        IndexBadge(index: index + 1, radius: 15),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TUserMenu(
                                icon: Icons.person_outline,
                                title: 'ชื่อผู้ใช้งาน',
                                value: '${user['username']}',
                              ),
                              TUserMenu(
                                icon: Icons.badge_outlined,
                                title: 'ชื่อ-นามสกุล',
                                value:
                                    '${user['first_nameid']}${user['firstName']} ${user['lastName']}',
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TUserMenu(
                                      icon: Icons.email_outlined,
                                      title: 'อีเมล',
                                      value: '${user['email']}',
                                    ),
                                  ),
                                  CircularIconButton(
                                    icon: Icons.copy,
                                    size: 16,
                                    color: Colors.blue[300]!,
                                    onTap: () async {
                                      Clipboard.setData(
                                        ClipboardData(text: '${user['email']}'),
                                      );
                                      _showSnackbar(
                                        context,
                                        'คัดลอกข้อมูลเรียบร้อยแล้ว',
                                      );
                                    },
                                  ),
                                ],
                              ),
                              TUserMenu(
                                icon: Icons.cake_outlined,
                                title: 'วันเดือนปีเกิด',
                                value: '${user['birthDate']}',
                              ),
                              const SizedBox(height: 8),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _ActionChip(
                                    icon: Icons.lock_reset,
                                    label: 'รีเซตรหัสผ่าน',
                                    onPressed: () async {
                                      bool? confirm =
                                          await _showConfirmationDialog(
                                            context,
                                          );
                                      if (confirm!) {
                                        await _fetchResetPass(
                                          '${user['username']}',
                                        );
                                      }
                                    },
                                  ),
                                  if (user['active'] == 0)
                                    _ActionChip(
                                      icon: Icons.how_to_reg_outlined,
                                      label: 'ยืนยันการสมัคร',
                                      onPressed: () async {
                                        bool? confirm =
                                            await _showConfirmationDialog(
                                              context,
                                            );
                                        if (confirm!) {
                                          await _fetchConfirmRegis(
                                            '${user['username']}',
                                          );
                                        }
                                      },
                                    ),
                                  if (user['permission_voice'] == 0)
                                    _ActionChip(
                                      icon: Icons.record_voice_over_outlined,
                                      label: 'กำหนดสิทธิ์ยืนยันเสียงอ่าน',
                                      onPressed: () async {
                                        bool? confirm =
                                            await _showConfirmationDialog(
                                              context,
                                            );
                                        if (confirm!) {
                                          await _fetchConfirmVoice(
                                            '${user['username']}',
                                            '1',
                                          );
                                        }
                                      },
                                    )
                                  else if (user['permission_voice'] == 1) ...[
                                    const _StatusPill(
                                      text: 'ยืนยันเสียงอ่านแล้ว',
                                    ),
                                    if (user['username'] != tmpUser)
                                      _ActionChip(
                                        icon: Icons.close,
                                        label: 'ยกเลิกสิทธิ์ยืนยันเสียงอ่าน',
                                        danger: true,
                                        onPressed: () async {
                                          bool? confirm =
                                              await _showConfirmationDialog(
                                                context,
                                              );
                                          if (confirm!) {
                                            await _fetchConfirmVoice(
                                              '${user['username']}',
                                              '0',
                                            );
                                          }
                                        },
                                      ),
                                  ],
                                  if (user['level_access'] == 2)
                                    _ActionChip(
                                      icon: Icons.admin_panel_settings_outlined,
                                      label: 'กำหนดสิทธิ์เป็น Admin',
                                      onPressed: () async {
                                        bool? confirm =
                                            await _showConfirmationDialog(
                                              context,
                                            );
                                        if (confirm!) {
                                          await _fetchConfirmAdmin(
                                            '${user['username']}',
                                            '1',
                                          );
                                        }
                                      },
                                    )
                                  else if (user['level_access'] == 1) ...[
                                    const _StatusPill(text: 'เป็น Admin'),
                                    if (user['username'] != tmpUser)
                                      _ActionChip(
                                        icon: Icons.close,
                                        label: 'ยกเลิกสิทธิ์ Admin',
                                        danger: true,
                                        onPressed: () async {
                                          bool? confirm =
                                              await _showConfirmationDialog(
                                                context,
                                              );
                                          if (confirm!) {
                                            await _fetchConfirmAdmin(
                                              '${user['username']}',
                                              '2',
                                            );
                                          }
                                        },
                                      ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // แถวแบบย่อ (โหมดลิสต์): บรรทัดเดียวต่อสมาชิก 1 คน รวมการจัดการสิทธิ์ทั้งหมด
  // ไว้ในเมนู ⋮ แทนการกางปุ่มเป็น chip หลายตัวแบบโหมดการ์ด เพื่อให้ไล่ดูสมาชิก
  // จำนวนมากได้เร็วกว่า
  Widget _buildListRow(BuildContext context, dynamic user, int index) {
    final isPendingRegis = user['active'] == 0;
    final isAdmin = user['level_access'] == 1;
    final canGrantAdmin = user['level_access'] == 2;
    final isVoiceConfirmed = user['permission_voice'] == 1;
    final canGrantVoice = user['permission_voice'] == 0;
    final isSelf = user['username'] == tmpUser;

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
          IndexBadge(index: index + 1, radius: 13),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${user['username']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: adaptiveTextColor(context),
                        ),
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      const _MiniTag(text: 'Admin', color: TColors.success),
                    ],
                    if (isPendingRegis) ...[
                      const SizedBox(width: 6),
                      const _MiniTag(text: 'รอยืนยัน', color: TColors.warning),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${user['email']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: adaptiveTextColor(context).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: adaptiveTextColor(context).withValues(alpha: 0.6),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.lock_reset),
                  title: Text('รีเซตรหัสผ่าน'),
                ),
              ),
              if (isPendingRegis)
                const PopupMenuItem(
                  value: 'confirmRegis',
                  child: ListTile(
                    leading: Icon(Icons.how_to_reg_outlined),
                    title: Text('ยืนยันการสมัคร'),
                  ),
                ),
              if (canGrantVoice)
                const PopupMenuItem(
                  value: 'grantVoice',
                  child: ListTile(
                    leading: Icon(Icons.record_voice_over_outlined),
                    title: Text('กำหนดสิทธิ์ยืนยันเสียงอ่าน'),
                  ),
                )
              else if (isVoiceConfirmed && !isSelf)
                const PopupMenuItem(
                  value: 'revokeVoice',
                  child: ListTile(
                    leading: Icon(Icons.voice_over_off_outlined),
                    title: Text('ยกเลิกสิทธิ์ยืนยันเสียงอ่าน'),
                  ),
                ),
              if (canGrantAdmin)
                const PopupMenuItem(
                  value: 'grantAdmin',
                  child: ListTile(
                    leading: Icon(Icons.admin_panel_settings_outlined),
                    title: Text('กำหนดสิทธิ์เป็น Admin'),
                  ),
                )
              else if (isAdmin && !isSelf)
                const PopupMenuItem(
                  value: 'revokeAdmin',
                  child: ListTile(
                    leading: Icon(Icons.remove_moderator_outlined),
                    title: Text('ยกเลิกสิทธิ์ Admin'),
                  ),
                ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'reset':
                  {
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm == true) {
                      await _fetchResetPass('${user['username']}');
                    }
                    break;
                  }
                case 'confirmRegis':
                  {
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm == true) {
                      await _fetchConfirmRegis('${user['username']}');
                    }
                    break;
                  }
                case 'grantVoice':
                  {
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm == true) {
                      await _fetchConfirmVoice('${user['username']}', '1');
                    }
                    break;
                  }
                case 'revokeVoice':
                  {
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm == true) {
                      await _fetchConfirmVoice('${user['username']}', '0');
                    }
                    break;
                  }
                case 'grantAdmin':
                  {
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm == true) {
                      await _fetchConfirmAdmin('${user['username']}', '1');
                    }
                    break;
                  }
                case 'revokeAdmin':
                  {
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm == true) {
                      await _fetchConfirmAdmin('${user['username']}', '2');
                    }
                    break;
                  }
              }
            },
          ),
        ],
      ),
    );
  }
}

// ป้ายข้อความเล็กมากแบบ inline ใช้ต่อท้ายชื่อผู้ใช้ในโหมดลิสต์
class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ปุ่มการทำงานขนาดเล็กแบบ chip ใช้แทนแถว InkWell+Icon+Text เดิมที่ไม่มีขอบเขต
// การแตะชัดเจน ให้ไหลต่อกันได้ด้วย Wrap แทนการจัดเรียงเป็น Row ตายตัว
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

// ป้ายสถานะแบบอ่านอย่างเดียว (ไม่ใช่ปุ่ม) บอกว่าบัญชีมีสิทธิ์นี้อยู่แล้ว
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 14, color: TColors.success),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
