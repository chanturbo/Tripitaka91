import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';

/// Single source of truth for the logged-in user across the app. Widgets
/// that watch this provider update immediately on login/logout/voice
/// change instead of relying on a full Phoenix.rebirth() restart or their
/// own one-off getUsersList() read.
class UserProvider extends ChangeNotifier {
  Users? _user;

  Users? get user => _user;
  bool get isLoggedIn => _user != null;

  UserProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = await getUsersList();
    notifyListeners();
  }

  void setUser(Users user) {
    _user = user;
    saveUsersList(user);
    notifyListeners();
  }

  void updateVoiceChoice(String voiceChoice) {
    if (_user == null) return;
    _user!.voiceChoice = voiceChoice;
    saveUsersList(_user!);
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    clearUsersList();
    notifyListeners();
  }
}
