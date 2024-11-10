import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/show_correct.dart';
import 'package:tripitaka91/widget/login/show_logedit_save.dart';
import 'package:tripitaka91/widget/login/show_member.dart';
import 'package:tripitaka91/widget/login/show_speech.dart';
import 'package:tripitaka91/widget/login/show_speech_save.dart';

class MemberTabShow extends StatelessWidget {
  final int indexShow;

  const MemberTabShow({
    super.key,
    required this.indexShow,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyTabMemberPage(
        indexShow: indexShow,
        pages: const [
          MyPageMemberTabDetail(indexLocal: 0),
          MyPageMemberTabDetail(indexLocal: 1),
          MyPageMemberTabDetail(indexLocal: 2),
          MyPageMemberTabDetail(indexLocal: 3),
          MyPageMemberTabDetail(indexLocal: 4),
        ],
      ),
    );
  }
}

class MyTabMemberPage extends StatelessWidget {
  final int indexShow;
  final List<MyPageMemberTabDetail> pages;

  const MyTabMemberPage({
    super.key,
    required this.indexShow,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: indexShow,
      length: pages.length,
      child: Scaffold(
        appBar: AppBar(
          title: const ATextDiskplayMedium(text: 'รายละเอียดข้อมูลสมาชิก'),
          bottom: const TabBar(
            indicatorColor: TColors.secondary,
            isScrollable: true,
            tabs: [
              Tab(child: ATextDiskplaySmall(text: 'ข้อมูลทั่วไป')),
              Tab(child: ATextDiskplaySmall(text: 'รายการแจ้งคำผิดคำถูก')),
              Tab(child: ATextDiskplaySmall(text: 'รายการแจ้งการอ่านออกเสียง')),
              Tab(child: ATextDiskplaySmall(text: 'ยืนยันการแก้ไขคำผิดคำถูก')),
              Tab(
                  child: ATextDiskplaySmall(
                      text: 'ยืนยันการแก้ไขการอ่านออกเสียง')),
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

class MyPageMemberTabDetail extends StatefulWidget {
  final int indexLocal;

  const MyPageMemberTabDetail({
    super.key,
    required this.indexLocal,
  });

  @override
  State<MyPageMemberTabDetail> createState() => _MyPageMemberTabDetailState();
}

class _MyPageMemberTabDetailState extends State<MyPageMemberTabDetail>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(2.5),
        child: widget.indexLocal == 0
            ? const MemberDisplay()
            : widget.indexLocal == 1
                ? const ShowSpeech()
                : widget.indexLocal == 2
                    ? const ShowSpeechSave()
                    : widget.indexLocal == 3
                        ? const ShowCorrect()
                        : const ShowCorrectSave(),
      ),
    );
  }
}
