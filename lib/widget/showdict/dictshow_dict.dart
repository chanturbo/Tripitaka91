import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/showdict/dict_alphabet_bar.dart';
import 'package:tripitaka91/widget/showdict/show_dict_list.dart';
import 'package:tripitaka91/widget/showdict/show_dict_list_2.dart';

class DictShowTitle extends StatefulWidget {
  final bool online;
  const DictShowTitle({super.key, required this.online});

  @override
  State<DictShowTitle> createState() => _DictShowTitleState();
}

class _DictShowTitleState extends State<DictShowTitle> {
  String dictSarabun = '...';
  final ScrollController _scrollControllerListView = ScrollController();
  bool loadFirst = false;

  void changeDictSarabun(String newDictSarabun) {
    setState(() {
      dictSarabun = newDictSarabun;
      loadFirst = !loadFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'พจนานุกรม ฉบับประมวลศัพท์',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              'รวบรวมโดย พระพรหมคุณาภรณ์ (ป.อ. ปยุตฺโต)',
              style: TextStyle(fontSize: 12, color: Color(0xB3FFFFFF)),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          DictAlphabetBar(
            scrollController: _scrollControllerListView,
            selected: dictSarabun,
            onSelect: changeDictSarabun,
          ),
          Expanded(
            child: loadFirst
                ? ShowPagesDictList(
                    wordSearch: dictSarabun,
                    online: widget.online,
                  )
                : ShowPagesDictList2(
                    wordSearch: dictSarabun,
                    online: widget.online,
                  ),
          ),
        ],
      ),
    );
  }
}
