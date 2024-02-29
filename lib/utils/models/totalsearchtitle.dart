// To parse this JSON data, do
//
//     final totalTitleSearch = totalTitleSearchFromJson(jsonString);

import 'dart:convert';

TotalTitleSearch totalTitleSearchFromJson(String str) =>
    TotalTitleSearch.fromJson(json.decode(str));

String totalTitleSearchToJson(TotalTitleSearch data) =>
    json.encode(data.toJson());

class TotalTitleSearch {
  int totalRecords;

  TotalTitleSearch({
    required this.totalRecords,
  });

  factory TotalTitleSearch.fromJson(Map<String, dynamic> json) =>
      TotalTitleSearch(
        totalRecords: int.parse(json["total_records"]),
      );

  Map<String, dynamic> toJson() => {
        "total_records": totalRecords,
      };
}
