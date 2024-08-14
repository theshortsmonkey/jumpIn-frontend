import 'dart:convert';
import 'dart:async';
import 'package:fe/utils/api_paths.dart';
import 'package:fe/utils/process_api_response.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart";
import 'package:fe/auth_provider.dart';
import "package:fe/classes/user_class.dart";

Future<ActiveSession> getCurrentSession() async {
  Uri url = Uri.parse('$baseUrl/users/currentUser');
  final response = await clientWithCredentials.get(url);
  final user = ActiveSession.fromJson(
      jsonDecode(processResponse(response)) as Map<String, dynamic>);
  return user;
}

Future<ActiveSession> postLogin(String username, String password) async {
  final bodyJson = jsonEncode({'password': password});
  Uri url = Uri.parse('$baseUrl/users/$username/login');
  try {
    final response = await clientWithCredentials.post(
      url,
      body: bodyJson,
    );
    final result = ActiveSession.fromJson(
        jsonDecode(processResponse(response)) as Map<String, dynamic>);
    return result;
  } on ClientException {
    throw Exception('server unavailable');
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<void> postLogout(String username) async {
  Uri url = Uri.parse('$baseUrl/users/$username/logout');
  final response = await clientWithCredentials.post(url);
  processResponse(response);
}

Future<List<User>> fetchUsers() async {
  Uri url = Uri.parse('$baseUrl/users');
  final response = await clientWithCredentials.get(url);
  List<User> users = jsonDecode(processResponse(response)).map<User>((item) {
    return User.fromJson(item as Map<String, dynamic>);
  }).toList();
  return users;
}

Future<User> fetchUserByUsername(username) async {
    Uri url = Uri.parse('$baseUrl/users/$username');
    final response = await clientWithCredentials.get(url);
    var user = User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return user;
}

Future<User> postUser(user) async {
  Uri url = Uri.parse('$baseUrl/users');
  String json = jsonEncode(user);
  final response = await clientWithCredentials.post(url,
      headers: {"Content-Type": "application/json"}, body: json);
  var result = User.fromJson(
      jsonDecode(processResponse(response)) as Map<String, dynamic>);
  return result;
}

Future<User> patchUser(user) async {
  String json = jsonEncode(user);
  Uri url = Uri.parse('$baseUrl/users/${user.username}');
  final response = await clientWithCredentials.patch(url,
      headers: {"Content-Type": "application/json"}, body: json);
  List<User> result = jsonDecode(processResponse(response)).map<User>((item) {
    return User.fromJson(item as Map<String, dynamic>);
  }).toList();
  return result[0];
}

Future fetchCarDetails(carReg) async {
  try {
    Uri url = Uri.parse(licenseURL);
    final response = await clientWithCredentials.post(
      url,
      headers: licenseHeaders,
      body: jsonEncode({'registrationNumber': carReg}),
    );
    final result = json.decode(processResponse(response));
    return result;
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("Error fetching car details: $e");
  }
}

Future<void> uploadUserProfilePic(String username, String filePath) async {
  Uri url = Uri.parse('$baseUrl/users/$username/image');
  final response = await clientWithCredentials.post(url,
      body: jsonEncode({'filePath': filePath}));
  return processResponse(response);
}

Future<void> deleteUser(user) async {
  final uri = Uri.parse("$baseUrl/users/${user.username}");
  final response = await clientWithCredentials.delete(uri);
  processResponse(response);
}
