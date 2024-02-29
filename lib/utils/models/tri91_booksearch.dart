// To parse this JSON data, do
//
//     final bookTri91 = bookTri91FromJson(jsonString);

import 'dart:convert';

List<Tri91BookSearch> tri91BookSearchFromJson(String str) =>
    List<Tri91BookSearch>.from(
        json.decode(str).map((x) => Tri91BookSearch.fromJson(x)));

String bookTri91ToJson(List<Tri91BookSearch> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Tri91BookSearch {
  int bookId;
  int totalRecords;

  Tri91BookSearch({
    required this.bookId,
    required this.totalRecords,
  });

  factory Tri91BookSearch.fromJson(Map<String, dynamic> json) =>
      Tri91BookSearch(
        bookId: json["book_id"],
        totalRecords: json["total_records"],
      );

  Map<String, dynamic> toJson() => {
        "book_id": bookId,
        "total_records": totalRecords,
      };
}
