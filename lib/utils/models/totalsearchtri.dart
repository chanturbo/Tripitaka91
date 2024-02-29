// To parse this JSON data, do
//
//     final totalTitleSearch = totalTitleSearchFromJson(jsonString);

import 'dart:convert';

TotalTitleSearchTri totalTitleSearchFromJson(String str) =>
    TotalTitleSearchTri.fromJson(json.decode(str));

String totalTitleSearchToJson(TotalTitleSearchTri data) =>
    json.encode(data.toJson());

class TotalTitleSearchTri {
  int totalRecords;
  String detailRecords;

  TotalTitleSearchTri({
    required this.totalRecords,
    required this.detailRecords,
  });

  factory TotalTitleSearchTri.fromJson(Map<String, dynamic> json) =>
      TotalTitleSearchTri(
        totalRecords: int.parse(json["total_records"]),
        detailRecords: json['detailRecords'],
      );

  Map<String, dynamic> toJson() => {
        "total_records": totalRecords,
        "detailRecords": detailRecords,
      };
}
