// To parse this JSON data, do
//
//     final soundsGetLink = soundsGetLinkFromJson(jsonString);

import 'dart:convert';

SoundsGetLink soundsGetLinkFromJson(String str) =>
    SoundsGetLink.fromJson(json.decode(str));

String soundsGetLinkToJson(SoundsGetLink data) => json.encode(data.toJson());

class SoundsGetLink {
  bool success;
  String message;

  SoundsGetLink({
    required this.success,
    required this.message,
  });

  factory SoundsGetLink.fromJson(Map<String, dynamic> json) => SoundsGetLink(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
