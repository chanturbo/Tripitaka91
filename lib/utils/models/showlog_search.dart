// To parse this JSON data, do
//
//     final logSearch = logSearchFromJson(jsonString);

import 'dart:convert';

List<LogSearch> logSearchFromJson(String str) =>
    List<LogSearch>.from(json.decode(str).map((x) => LogSearch.fromJson(x)));

String logSearchToJson(List<LogSearch> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LogSearch {
  String username;
  String keyword;
  int count;
  DateTime timestamp;

  LogSearch({
    required this.username,
    required this.keyword,
    required this.count,
    required this.timestamp,
  });

  factory LogSearch.fromJson(Map<String, dynamic> json) => LogSearch(
        username: json["username"],
        keyword: json["keyword"],
        count: json["count"],
        timestamp: DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "keyword": keyword,
        "count": count,
        "timestamp": timestamp.toIso8601String(),
      };
}
