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
  int active;
  int levelAccess;
  String counterWordcorrec;

  User({
    required this.username,
    required this.password,
    required this.firstNameid,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    required this.active,
    required this.levelAccess,
    required this.counterWordcorrec,
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
      active: json["active"] ?? "0",
      levelAccess: json["level_access"] ?? "2",
      counterWordcorrec: json["counter_wordcorrec"] ?? "",
    );
  }
}
