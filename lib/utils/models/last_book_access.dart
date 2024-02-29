// To parse this JSON data, do
//
//     final lastBookAccess = lastBookAccessFromJson(jsonString);

import 'dart:convert';

List<LastBookAccessSuccess> lastBookAccessSuccessFromJson(String str) =>
    List<LastBookAccessSuccess>.from(
      json.decode(str).map((x) => LastBookAccessSuccess.fromJson(x)),
    );

String lastBookAccessSuccessToJson(List<LastBookAccessSuccess> data) =>
    json.encode(
      List<dynamic>.from(data.map((x) => x.toJson())),
    );

class LastBookAccessSuccess {
  bool success;
  String message;
  List<LastBookAccess> data;

  LastBookAccessSuccess({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LastBookAccessSuccess.fromJson(Map<String, dynamic> json) {
    return LastBookAccessSuccess(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: List<LastBookAccess>.from(
        [
          LastBookAccess.fromJson(json['data'] ?? {})
        ], // นี้คือการสร้าง List ที่มีเพียงรายการเดียว
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

List<LastBookAccess> lastBookAccessFromJson(String str) =>
    List<LastBookAccess>.from(
        json.decode(str).map((x) => LastBookAccess.fromJson(x)));

String lastBookAccessToJson(List<LastBookAccess> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LastBookAccess {
  String username;
  DateTime timeLastAccess;
  int bookLastAccess;
  int pageLastAccess;

  LastBookAccess({
    required this.username,
    required this.timeLastAccess,
    required this.bookLastAccess,
    required this.pageLastAccess,
  });

  factory LastBookAccess.fromJson(Map<String, dynamic> json) => LastBookAccess(
        username: json["username"],
        timeLastAccess: DateTime.parse(json["time_last_access"]),
        bookLastAccess: json["book_last_access"],
        pageLastAccess: json["page_last_access"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "time_last_access": timeLastAccess.toIso8601String(),
        "book_last_access": bookLastAccess,
        "page_last_access": pageLastAccess,
      };
}
