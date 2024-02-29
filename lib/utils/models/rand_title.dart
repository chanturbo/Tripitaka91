// To parse this JSON data, do
//
//     final randTitle = randTitleFromJson(jsonString);

import 'dart:convert';

List<RandTitle> randTitleFromJson(String str) =>
    List<RandTitle>.from(json.decode(str).map((x) => RandTitle.fromJson(x)));

String randTitleToJson(List<RandTitle> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RandTitle {
  int tripitaka91No;
  double tripitaka91Code;
  String tripitaka91Title;
  String tripitaka91Detail;
  String tripitaka91Category;
  String tripitaka91Group;
  String tripitaka91BookBlue;
  String tripitaka91BookRed;
  String tripitaka91Mark;
  String tripitaka91Readfromfile;
  int tripitaka91Book;
  int tripitaka91Page;
  int tripitaka91Line;

  RandTitle({
    required this.tripitaka91No,
    required this.tripitaka91Code,
    required this.tripitaka91Title,
    required this.tripitaka91Detail,
    required this.tripitaka91Category,
    required this.tripitaka91Group,
    required this.tripitaka91BookBlue,
    required this.tripitaka91BookRed,
    required this.tripitaka91Mark,
    required this.tripitaka91Readfromfile,
    required this.tripitaka91Book,
    required this.tripitaka91Page,
    required this.tripitaka91Line,
  });

  factory RandTitle.fromJson(Map<String, dynamic> json) => RandTitle(
        tripitaka91No: json["tripitaka91_no"] ?? 0,
        tripitaka91Code: json["tripitaka91_code"]?.toDouble() ?? 0.0,
        tripitaka91Title: json["tripitaka91_title"] ?? "",
        tripitaka91Detail: json["tripitaka91_detail"] ?? "",
        tripitaka91Category: json["tripitaka91_category"] ?? "",
        tripitaka91Group: json["tripitaka91_group"] ?? "",
        tripitaka91BookBlue: json["tripitaka91_book_blue"] ?? "-",
        tripitaka91BookRed: json["tripitaka91_book_red"] ?? "-",
        tripitaka91Mark: json["tripitaka91_mark"] ?? "",
        tripitaka91Readfromfile: json["tripitaka91_readfromfile"] ?? "",
        tripitaka91Book: json["tripitaka91_book"] ?? 0,
        tripitaka91Page: json["tripitaka91_page"] ?? 0,
        tripitaka91Line: json["tripitaka91_line"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "tripitaka91_no": tripitaka91No,
        "tripitaka91_code": tripitaka91Code,
        "tripitaka91_title": tripitaka91Title,
        "tripitaka91_detail": tripitaka91Detail,
        "tripitaka91_category": tripitaka91Category,
        "tripitaka91_group": tripitaka91Group,
        "tripitaka91_book_blue": tripitaka91BookBlue,
        "tripitaka91_book_red": tripitaka91BookRed,
        "tripitaka91_mark": tripitaka91Mark,
        "tripitaka91_readfromfile": tripitaka91Readfromfile,
        "tripitaka91_book": tripitaka91Book,
        "tripitaka91_page": tripitaka91Page,
        "tripitaka91_line": tripitaka91Line,
      };
}
