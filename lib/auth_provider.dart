import 'package:fe/utils/api.dart';
import 'package:flutter/material.dart';

class ActiveSession {
  final String username;
  final bool isDriver;

  const ActiveSession ({
    this.username = '',
    this.isDriver = false,
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      username: json['username'] as String,
      isDriver: json['isDriver'] as bool
    );
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
      final user = await getCurrentSession();
      print('active session');
      return user;
    } catch (e) {
      print('no active user');
      return const ActiveSession();
    }
  } 
}
