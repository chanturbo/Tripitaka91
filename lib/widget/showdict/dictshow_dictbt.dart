import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/showdict/dict_alphabet_bar.dart';
import 'package:tripitaka91/widget/showdict/show_dictbt_list.dart';
import 'package:tripitaka91/widget/showdict/show_dictbt_list_2.dart';

class DictbtShowTitle extends StatefulWidget {
  final bool online;
  const DictbtShowTitle({super.key, required this.online});

  @override
  State<DictbtShowTitle> createState() => _DictbtShowTitleState();
}

class _DictbtShowTitleState extends State<DictbtShowTitle> {
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
        title: const Text(
          'พจนานุกรม ไทย-บาลี',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                ? ShowPagesDictbtList(
                    wordSearch: dictSarabun,
                    online: widget.online,
                  )
                : ShowPagesDictbtList2(
                    wordSearch: dictSarabun,
                    online: widget.online,
                  ),
          ),
        ],
      ),
    );
  }
}
