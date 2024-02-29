// To parse this JSON data, do
//
//     final logEditShow = logEditShowFromJson(jsonString);

import 'dart:convert';

List<LogEditShow> logEditShowFromJson(String str) => List<LogEditShow>.from(
    json.decode(str).map((x) => LogEditShow.fromJson(x)));

String logEditShowToJson(List<LogEditShow> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LogEditShow {
  int tripitaka91Book;
  int tripitaka91Page;
  int tripitaka91Line;
  String detailOld;
  String detailNew;
  String wordincorrect;
  String wordcorrect;
  String? wordcorrectcomment;
  int wordsum;
  String users;
  DateTime dateadd;
  DateTime dateadd1;
  DateTime dateedit;
  DateTime? dateedit1;
  String ip;

  LogEditShow({
    required this.tripitaka91Book,
    required this.tripitaka91Page,
    required this.tripitaka91Line,
    required this.detailOld,
    required this.detailNew,
    required this.wordincorrect,
    required this.wordcorrect,
    required this.wordcorrectcomment,
    required this.wordsum,
    required this.users,
    required this.dateadd,
    required this.dateadd1,
    required this.dateedit,
    required this.dateedit1,
    required this.ip,
  });

  factory LogEditShow.fromJson(Map<String, dynamic> json) => LogEditShow(
        tripitaka91Book: json["tripitaka91_book"],
        tripitaka91Page: json["tripitaka91_page"],
        tripitaka91Line: json["tripitaka91_line"],
        detailOld: json["detail_old"],
        detailNew: json["detail_new"],
        wordincorrect: json["wordincorrect"],
        wordcorrect: json["wordcorrect"],
        wordcorrectcomment: json["wordcorrectcomment"],
        wordsum: json["wordsum"],
        users: json["users"],
        dateadd: DateTime.parse(json["dateadd"]),
        dateadd1: DateTime.parse(json["dateadd1"]),
        dateedit: DateTime.parse(json["dateedit"]),
        dateedit1: json["dateedit1"] == null
            ? null
            : DateTime.parse(json["dateedit1"]),
        ip: json["ip"],
      );

  Map<String, dynamic> toJson() => {
        "tripitaka91_book": tripitaka91Book,
        "tripitaka91_page": tripitaka91Page,
        "tripitaka91_line": tripitaka91Line,
        "detail_old": detailOld,
        "detail_new": detailNew,
        "wordincorrect": wordincorrect,
        "wordcorrect": wordcorrect,
        "wordcorrectcomment": wordcorrectcomment,
        "wordsum": wordsum,
        "users": users,
        "dateadd": dateadd.toIso8601String(),
        "dateadd1":
            "${dateadd1.year.toString().padLeft(4, '0')}-${dateadd1.month.toString().padLeft(2, '0')}-${dateadd1.day.toString().padLeft(2, '0')}",
        "dateedit": dateedit.toIso8601String(),
        "dateedit1":
            "${dateedit1!.year.toString().padLeft(4, '0')}-${dateedit1!.month.toString().padLeft(2, '0')}-${dateedit1!.day.toString().padLeft(2, '0')}",
        "ip": ip,
      };
}
