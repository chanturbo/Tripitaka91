import 'dart:convert';

List<Logedit> logeditFromJson(String str) =>
    List<Logedit>.from(json.decode(str).map((x) => Logedit.fromJson(x)));

String logeditToJson(List<Logedit> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Logedit {
  int tripitaka91Book;
  int tripitaka91Page;
  int tripitaka91Line;
  String bookDetailOld;
  String bookDetailNew;
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
  int bookConfirm;
  int bookSuscess;
  String firstNameid;
  String firstName;
  String lastName;

  Logedit({
    required this.tripitaka91Book,
    required this.tripitaka91Page,
    required this.tripitaka91Line,
    required this.bookDetailOld,
    required this.bookDetailNew,
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
    required this.bookConfirm,
    required this.bookSuscess,
    this.firstNameid = '',
    this.firstName = '',
    this.lastName = '',
  })  : tripitaka91Wordcorrectcomment = tripitaka91Wordcorrectcomment ?? '',
        tripitaka91Dateedit1 = tripitaka91Dateedit1 ?? DateTime.now();

  factory Logedit.fromJson(Map<String, dynamic> json) => Logedit(
        tripitaka91Book: json["tripitaka91_book"],
        tripitaka91Page: json["tripitaka91_page"],
        tripitaka91Line: json["tripitaka91_line"],
        bookDetailOld: json["book_detail_old"] ?? '',
        bookDetailNew: json["book_detail_new"] ?? '',
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
        bookConfirm: json["book_confirm"],
        bookSuscess: json["book_suscess"],
        firstNameid: json["first_nameid"],
        firstName: json["firstName"],
        lastName: json["lastName"],
      );

  Map<String, dynamic> toJson() => {
        "tripitaka91_book": tripitaka91Book,
        "tripitaka91_page": tripitaka91Page,
        "tripitaka91_line": tripitaka91Line,
        "book_detail_old": bookDetailOld,
        "book_detail_new": bookDetailNew,
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
        "book_confirm": bookConfirm,
        "book_suscess": bookSuscess,
        "first_nameid": firstNameid,
        "firstName": firstName,
        "lastName": lastName,
      };
}
