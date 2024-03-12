import 'dart:convert';

List<LogeditSave> logeditSaveFromJson(String str) => List<LogeditSave>.from(
    json.decode(str).map((x) => LogeditSave.fromJson(x)));

String logeditSaveToJson(List<LogeditSave> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LogeditSave {
  int tripitaka91Book;
  int tripitaka91Page;
  int tripitaka91Line;
  String tripitaka91Detail;
  String tripitaka91Wordincorrect;
  String tripitaka91Wordcorrect;
  String tripitaka91Wordcorrectcomment;
  int tripitaka91Wordsum;
  String tripitaka91User;
  DateTime tripitaka91Dateadd;
  DateTime tripitaka91Dateadd1;
  DateTime tripitaka91Dateedit;
  DateTime tripitaka91Dateedit1;
  String tripitaka91Ip;

  LogeditSave({
    required this.tripitaka91Book,
    required this.tripitaka91Page,
    required this.tripitaka91Line,
    required this.tripitaka91Detail,
    required this.tripitaka91Wordincorrect,
    required this.tripitaka91Wordcorrect,
    String? tripitaka91Wordcorrectcomment,
    required this.tripitaka91Wordsum,
    required this.tripitaka91User,
    required this.tripitaka91Dateadd,
    required this.tripitaka91Dateadd1,
    required this.tripitaka91Dateedit,
    DateTime? tripitaka91Dateedit1,
    required this.tripitaka91Ip,
  })  : tripitaka91Wordcorrectcomment = tripitaka91Wordcorrectcomment ?? '',
        tripitaka91Dateedit1 = tripitaka91Dateedit1 ?? DateTime.now();

  factory LogeditSave.fromJson(Map<String, dynamic> json) => LogeditSave(
        tripitaka91Book: json["tripitaka91_book"],
        tripitaka91Page: json["tripitaka91_page"],
        tripitaka91Line: json["tripitaka91_line"],
        tripitaka91Detail: json["book_detail_old"],
        tripitaka91Wordincorrect: json["tripitaka91_wordincorrect"],
        tripitaka91Wordcorrect: json["tripitaka91_wordcorrect"],
        tripitaka91Wordcorrectcomment: json["tripitaka91_wordcorrectcomment"],
        tripitaka91Wordsum: json["tripitaka91_wordsum"],
        tripitaka91User: json["tripitaka91_user"],
        tripitaka91Dateadd: DateTime.parse(json["tripitaka91_dateadd"]),
        tripitaka91Dateadd1: DateTime.parse(json["tripitaka91_dateadd1"]),
        tripitaka91Dateedit: DateTime.parse(json["tripitaka91_dateedit"]),
        tripitaka91Dateedit1: json["tripitaka91_dateedit1"] == null
            ? null
            : DateTime.parse(json["tripitaka91_dateedit1"]),
        tripitaka91Ip: json["tripitaka91_ip"],
      );

  Map<String, dynamic> toJson() => {
        "tripitaka91_book": tripitaka91Book,
        "tripitaka91_page": tripitaka91Page,
        "tripitaka91_line": tripitaka91Line,
        "book_detail_old": tripitaka91Detail,
        "tripitaka91_wordincorrect": tripitaka91Wordincorrect,
        "tripitaka91_wordcorrect": tripitaka91Wordcorrect,
        "tripitaka91_wordcorrectcomment": tripitaka91Wordcorrectcomment,
        "tripitaka91_wordsum": tripitaka91Wordsum,
        "tripitaka91_user": tripitaka91User,
        "tripitaka91_dateadd": tripitaka91Dateadd.toIso8601String(),
        "tripitaka91_dateadd1":
            "${tripitaka91Dateadd1.year.toString().padLeft(4, '0')}-${tripitaka91Dateadd1.month.toString().padLeft(2, '0')}-${tripitaka91Dateadd1.day.toString().padLeft(2, '0')}",
        "tripitaka91_dateedit": tripitaka91Dateedit.toIso8601String(),
        "tripitaka91_dateedit1":
            "${tripitaka91Dateedit1.year.toString().padLeft(4, '0')}-${tripitaka91Dateedit1.month.toString().padLeft(2, '0')}-${tripitaka91Dateedit1.day.toString().padLeft(2, '0')}",
        "tripitaka91_ip": tripitaka91Ip,
      };
}
