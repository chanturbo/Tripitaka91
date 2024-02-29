// To parse this JSON data, do
//
//     final jsonApiStatus = jsonApiStatusFromJson(jsonString);

import 'dart:convert';

List<JsonApiStatus> jsonApiStatusFromJson(String str) =>
    List<JsonApiStatus>.from(
        json.decode(str).map((x) => JsonApiStatus.fromJson(x)));

String jsonApiStatusToJson(List<JsonApiStatus> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class JsonApiStatus {
  bool success;
  String message;

  JsonApiStatus({
    required this.success,
    required this.message,
  });

  factory JsonApiStatus.fromJson(Map<String, dynamic> json) => JsonApiStatus(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
