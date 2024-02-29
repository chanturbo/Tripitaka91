// To parse this JSON data, do
//
//     final bookTri91 = bookTri91FromJson(jsonString);

import 'dart:convert';

List<BookTri91> bookTri91FromJson(String str) =>
    List<BookTri91>.from(json.decode(str).map((x) => BookTri91.fromJson(x)));

String bookTri91ToJson(List<BookTri91> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BookTri91 {
  int bookId;
  int bookPages;
  int bookLine;
  String bookDetail;
  int bookLines;
  DateTime? bookEdit;
  String? bookDict;
  String? bookDetailOld;

  BookTri91({
    required this.bookId,
    required this.bookPages,
    required this.bookLine,
    required this.bookDetail,
    required this.bookLines,
    required this.bookEdit,
    this.bookDict,
    this.bookDetailOld,
  });

  factory BookTri91.fromJson(Map<String, dynamic> json) => BookTri91(
        bookId: json["book_id"],
        bookPages: json["book_pages"],
        bookLine: json["book_line"],
        bookDetail: json["book_detail"],
        bookLines: json["book_lines"],
        bookEdit: json["book_edit"] != null
            ? DateTime.parse(json["book_edit"])
            : null,
        bookDict: json["book_dict"],
        bookDetailOld: json["book_detail_old"],
      );

  Map<String, dynamic> toJson() => {
        "book_id": bookId,
        "book_pages": bookPages,
        "book_line": bookLine,
        "book_detail": bookDetail,
        "book_lines": bookLines,
        "book_edit": bookEdit,
        "book_dict": bookDict,
        "book_detail_old": bookDetailOld,
      };
}
