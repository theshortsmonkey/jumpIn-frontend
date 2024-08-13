import 'dart:convert';
import 'dart:async';
import 'package:fe/utils/process_api_response.dart';
import "package:http/http.dart" as http;
import 'package:enhanced_http/enhanced_http.dart';
import 'package:fe/auth_provider.dart';
import "package:fe/classes/user_class.dart";

EnhancedHttp httpEnhanced = EnhancedHttp(
  baseURL: 'https://localhost:1337',
  );
// EnhancedHttp httpEnhanced = EnhancedHttp(baseURL: 'https://jumpin-backend.onrender.com');

const baseHost = 'localhost:1337';
const baseUrl = 'https://$baseHost';
// const baseHost = 'jumpin-backend.onrender.com';
// const baseUrl = 'https://$baseHost';

Future<ActiveSession> getCurrentSession() async {
  Uri url = Uri.parse('$baseUrl/users/currentUser');
  final response = await http.get(url);
  final user = ActiveSession.fromJson(
      jsonDecode(processResponse(response)) as Map<String, dynamic>);
  return user;
}

Future<ActiveSession> postLogin(String username, String password) async {
  final bodyJson = jsonEncode({'password': password});
  Uri url = Uri.parse('$baseUrl/users/$username/login');
  try {
    final response = await http.post(url, body: bodyJson,);
    final result = ActiveSession.fromJson(jsonDecode(processResponse(response)) as Map<String, dynamic>);
    return result;
  } on ClientException {
    throw Exception('server unavailable');
  } catch (e) {
    throw Exception(e.toString());
  } 
}

Future<void> postLogout(String username) async {
  Uri url = Uri.parse('$baseUrl/users/$username/logout');
  final response = await http.post(url);
  processResponse(response);
}

Future<List<User>> fetchUsers() async {
  final response = await httpEnhanced.get('/users');
  if (response.isNotEmpty) {
    List<User> users = response.map<User>((item) {
      return User.fromJson(item as Map<String, dynamic>);
    }).toList();
    return users;
  } else {
    throw Exception('No users found');
  }
}

Future<User> fetchUserByUsername(username) async {
  try {
    Uri url = Uri.parse('$baseUrl/users/$username');
    final response = await http.get(url);
    var user = User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return user;
  } catch (e) {
    throw Exception('No users found');
  }
}

Future<User> postUser(user) async {
  Uri url = Uri.parse('$baseUrl/users');
  String json = jsonEncode(user);
  final response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: json);
  var result = User.fromJson(
      jsonDecode(processResponse(response)) as Map<String, dynamic>);
  return result;
}

Future<User> patchUser(user) async {
  String json = jsonEncode(user);
  Uri url = Uri.parse('$baseUrl/users/${user.username}');
  final response = await http.patch(url,
      headers: {"Content-Type": "application/json"}, body: json);
  List<User> result = jsonDecode(processResponse(response)).map<User>((item) {
    return User.fromJson(item as Map<String, dynamic>);
  }).toList();
  return result[0];
}

Future fetchCarDetails(carReg) async {
  try {
    Uri url = Uri.parse(
        'https://driver-vehicle-licensing.api.gov.uk/vehicle-enquiry/v1/vehicles');
    final response = await http.post(
      url,
      headers: {
        'x-api-key': '1gZwZ4vfFN1TbScqIP7FG4ccTa8SkB95aJN9wHBs',
        "accept": '*/*',
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD"
      },
      body: jsonEncode({'registrationNumber': carReg}),
    );
    final result = json.decode(processResponse(response));
    return result;
  } catch (e) {
    throw Exception("Error fetching car details: $e");
  }
}

Future<void> uploadUserProfilePic(String username, String filePath) async {
  Uri url = Uri.parse('$baseUrl/users/$username/image');
  final response =
      await http.post(url, body: jsonEncode({'filePath': filePath}));
  return processResponse(response);
}

Future<void> deleteUser(user) async {
  final uri = Uri.parse("$baseUrl/users/${user.username}");
  final response = await http.delete(uri);
  processResponse(response);
}
