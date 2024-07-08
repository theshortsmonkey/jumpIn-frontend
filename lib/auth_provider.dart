import 'package:flutter/material.dart';
import 'package:fe/utils/api.dart';

class ActiveSession {
  final String username;
  final bool isDriver;

  const ActiveSession({
    this.username = '',
    this.isDriver = false,
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
        username: json['username'] as String,
        isDriver: json['isDriver'] as bool);
  }
}

class AuthState extends ChangeNotifier {
  ActiveSession _user = const ActiveSession();
  ActiveSession get userInfo => _user;
  void setActiveSession(ActiveSession user) {
    _user = user;
    notifyListeners();
  }

  void logout() async {
    await postLogout(_user.username);
    _user = const ActiveSession();
    notifyListeners();
  }

  bool get isAuthorized {
    return _user.username.isNotEmpty;
  }

  Future<ActiveSession> checkActiveSession() async {
    try {
      _user = await getCurrentSession();
      return _user;
    } catch (e) {
      _user = const ActiveSession();
      return _user;
    }
  }
}
