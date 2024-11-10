class UsersLogin {
  bool success;
  String message;
  User user;

  UsersLogin({
    required this.success,
    required this.message,
    required this.user,
  });

  factory UsersLogin.fromJson(Map<String, dynamic> json) {
    return UsersLogin(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class User {
  String username;
  String password;
  String firstNameid;
  String firstName;
  String lastName;
  DateTime birthDate;
  String email;
  String voiceChoice;
  int active;
  int levelAccess;
  int permissionVoice;
  String counterWordcorrec;
  int permissionLogEdit;

  User({
    required this.username,
    required this.password,
    required this.firstNameid,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    required this.voiceChoice,
    required this.active,
    required this.levelAccess,
    required this.permissionVoice,
    required this.counterWordcorrec,
    required this.permissionLogEdit,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json["username"] ?? "",
      password: json["password"] ?? "",
      firstNameid: json["first_nameid"] ?? "",
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
      birthDate: json["birthDate"] != null
          ? DateTime.parse(json["birthDate"])
          : DateTime.now(),
      email: json["email"] ?? "",
      voiceChoice: json["voice_choice"] ?? "เสียงผู้ชาย",
      active: json["active"] ?? "0",
      levelAccess: json["level_access"] ?? "2",
      permissionVoice: json["permission_voice"] ?? "0",
      counterWordcorrec: json["counter_wordcorrec"] ?? "",
      permissionLogEdit: json["permission_logedit"] ?? "0",
    );
  }
}
