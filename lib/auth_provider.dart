import 'package:fe/api.dart';
import 'package:flutter/material.dart';
import "classes/user_class.dart";

class AuthState extends ChangeNotifier {
  User _user = const User();
  User get userInfo => _user;
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void logout() async {
    await postLogout(_user.username);
    _user = const User();
    notifyListeners();
  }

  bool get isAuthorized {
    return _user.username.isNotEmpty;
  }

  Future<bool> checkActiveSession() async {
    try {
      final user = await getCurrentUser();
      _user = user;
      notifyListeners();
      return true; // has a login record.
    } catch (e) {
      return false;
    }
  }
}
