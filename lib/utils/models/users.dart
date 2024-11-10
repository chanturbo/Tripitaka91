// To parse this JSON data, do
//
//     final users = usersFromJson(jsonString);

import 'dart:convert';

Users usersFromJson(String str) => Users.fromJson(json.decode(str));

String usersToJson(Users data) => json.encode(data.toJson());

class Users {
  String username;
  String password;
  // String gender;
  String firstNameid;
  String firstName;
  String lastName;
  DateTime birthDate;
  String email;
  // String dialingCode;
  // String phone;
  // String memberOccupation;
  // String memberAddress;
  // String memberRoad;
  // String memberTambon;
  // String memberAmphur;
  // String memberProvince;
  // String memberPost;
  // String codeCountry;
  // String country;
  String voiceChoice;
  // String imgPath;
  String active;
  String levelAccess;
  String permissionVoice;
  // DateTime regDate;
  // String lastActive;
  // String ip;
  // DateTime regConfirm;
  String counterWordcorrec;
  String permissionLogEdit;

  Users({
    required this.username,
    required this.password,
    // required this.gender,
    required this.firstNameid,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    // required this.dialingCode,
    // required this.phone,
    // required this.memberOccupation,
    // required this.memberAddress,
    // required this.memberRoad,
    // required this.memberTambon,
    // required this.memberAmphur,
    // required this.memberProvince,
    // required this.memberPost,
    // required this.codeCountry,
    // required this.country,
    required this.voiceChoice,
    // required this.imgPath,
    required this.active,
    required this.levelAccess,
    required this.permissionVoice,
    // required this.regDate,
    // required this.lastActive,
    // required this.ip,
    // required this.regConfirm,
    required this.counterWordcorrec,
    required this.permissionLogEdit,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      username: json["username"] ?? "",
      password: json["password"] ?? "",
      // gender: json["gender"] ?? "",
      firstNameid: json["first_nameid"] ?? "",
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
      birthDate: json["birthDate"] != null
          ? DateTime.parse(json["birthDate"])
          : DateTime.now(),
      email: json["email"] ?? "",
      // dialingCode: json["dialing_code"] ?? "",
      // phone: json["phone"] ?? "",
      // memberOccupation: json["member_occupation"] ?? "",
      // memberAddress: json["member_address"] ?? "",
      // memberRoad: json["member_road"] ?? "",
      // memberTambon: json["member_tambon"] ?? "",
      // memberAmphur: json["member_amphur"] ?? "",
      // memberProvince: json["member_province"] ?? "",
      // memberPost: json["member_post"] ?? "",
      // codeCountry: json["code_country"] ?? "",
      // country: json["country"] ?? "",
      voiceChoice: json["voice_choice"] ?? "เสียงผู้ชาย",
      // imgPath: json["img_path"] ?? "",
      active: json["active"] ?? "0",
      levelAccess: json["level_access"] ?? "",
      permissionVoice: json["permission_voice"] ?? "0",
      // regDate: json["reg_date"] != null
      //     ? DateTime.parse(json["reg_date"])
      //     : DateTime.now(),
      // lastActive: json["last_active"] ?? "",
      // ip: json["ip"] ?? "",
      // regConfirm: json["reg_confirm"] != null
      //     ? DateTime.parse(json["reg_confirm"])
      //     : DateTime.now(),
      counterWordcorrec: json["counter_wordcorrec"] ?? "",
      permissionLogEdit: json["permission_logedit"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
        // "gender": gender,
        "first_nameid": firstNameid,
        "firstName": firstName,
        "lastName": lastName,
        "birthDate":
            "${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}",
        "email": email,
        // "dialing_code": dialingCode,
        // "phone": phone,
        // "member_occupation": memberOccupation,
        // "member_address": memberAddress,
        // "member_road": memberRoad,
        // "member_tambon": memberTambon,
        // "member_amphur": memberAmphur,
        // "member_province": memberProvince,
        // "member_post": memberPost,
        // "code_country": codeCountry,
        // "country": country,
        "voice_choice": voiceChoice,
        // "img_path": imgPath,
        "active": active,
        "level_access": levelAccess,
        "permission_voice": permissionVoice,
        // "reg_date": regDate.toIso8601String(),
        // "last_active": lastActive,
        // "ip": ip,
        // "reg_confirm": regConfirm.toIso8601String(),
        "counter_wordcorrec": counterWordcorrec,
        "permission_logedit": permissionLogEdit,
      };
}
