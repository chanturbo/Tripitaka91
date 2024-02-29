// To parse this JSON data, do
//
//     final tri91BookAll = tri91BookAllFromMap(jsonString);

import 'dart:convert';

List<Tri91BookAll> tri91BookAllFromMap(String str) => List<Tri91BookAll>.from(
    json.decode(str).map((x) => Tri91BookAll.fromMap(x)));

String tri91BookAllToMap(List<Tri91BookAll> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

List<Tri91BookAll> tri91BookAllFromJson(String str) => List<Tri91BookAll>.from(
    json.decode(str).map((x) => Tri91BookAll.fromJson(x)));

String tri91BookAllToJson(List<Tri91BookAll> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Tri91BookAll {
  Tri91BookAll({
    required this.bookIds,
    required this.bookTitleTri,
    required this.bookDetail,
    required this.bookPagesTotal,
    required this.bookReadall,
    required this.bookLastAccess,
    required this.bookLastPages,
    required this.bookLastLine,
    required this.tmp1,
  });

  double bookIds;
  String bookTitleTri;
  String bookDetail;
  int bookPagesTotal;
  int bookReadall;
  String bookLastAccess;
  int bookLastPages;
  int bookLastLine;
  String tmp1;

  factory Tri91BookAll.fromMap(Map<String, dynamic> json) => Tri91BookAll(
        bookIds: json["book_ids"].toDouble(),
        bookTitleTri: json["book_title_tri"],
        bookDetail: json["book_detail"],
        bookPagesTotal: json["book_pages_total"],
        bookReadall: json["book_readall"],
        bookLastAccess: json["book_last_access"],
        bookLastPages: json["book_last_pages"],
        bookLastLine: json["book_last_line"],
        tmp1: json["tmp_1"],
      );

  Map<String, dynamic> toMap() => {
        "book_ids": bookIds,
        "book_title_tri": bookTitleTri,
        "book_detail": bookDetail,
        "book_pages_total": bookPagesTotal,
        "book_readall": bookReadall,
        "book_last_access": bookLastAccess,
        "book_last_pages": bookLastPages,
        "book_last_line": bookLastLine,
        "tmp_1": tmp1,
      };

  factory Tri91BookAll.fromJson(Map<String, dynamic> json) => Tri91BookAll(
        bookIds: json["book_ids"].toDouble(),
        bookTitleTri: json["book_title_tri"],
        bookDetail: json["book_detail"],
        bookPagesTotal: json["book_pages_total"],
        bookReadall: json["book_readall"],
        bookLastAccess: json["book_last_access"],
        bookLastPages: json["book_last_pages"],
        bookLastLine: json["book_last_line"],
        tmp1: json["tmp_1"],
      );

  Map<String, dynamic> toJson() => {
        "book_ids": bookIds,
        "book_title_tri": bookTitleTri,
        "book_detail": bookDetail,
        "book_pages_total": bookPagesTotal,
        "book_readall": bookReadall,
        "book_last_access": bookLastAccess,
        "book_last_pages": bookLastPages,
        "book_last_line": bookLastLine,
        "tmp_1": tmp1,
      };
}
