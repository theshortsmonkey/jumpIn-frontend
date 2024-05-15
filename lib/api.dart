import 'dart:convert';
import 'package:enhanced_http/enhanced_http.dart';
import 'classes/ride_class.dart';
import 'classes/message_class.dart';
import 'classes/chat_class.dart';
import 'dart:async';
import "classes/user_class.dart";
import "package:http/http.dart" as http;

EnhancedHttp httpEnhanced = EnhancedHttp(baseURL: 'http://localhost:1337');
EnhancedHttp httpGeoapify =
    EnhancedHttp(baseURL: 'https://api.geoapify.com/v1/routing');
EnhancedHttp httpGeocode =
    EnhancedHttp(baseURL: 'https://api.geoapify.com/v1/geocode');
EnhancedHttp httpFuel = EnhancedHttp(baseURL: 'https://www.bp.com');

const baseUrl = 'http://localhost:1337';

Future<List<Ride>> fetchRides(
    {String? to,
    String? from,
    String? getDateTime,
    int? price,
    int? getAvailableSeats,
    int? carbonEmissions}) async {
  final queryParams = <String, dynamic>{};
  if (to?.isNotEmpty ?? false) {
    queryParams['to'] = to;
  }
  if (from?.isNotEmpty ?? false) {
    queryParams['from'] = from;
  }
  if (getDateTime != null) {
    queryParams['date_and_time'] = getDateTime;
  }
  if (price != null) {
    queryParams['price'] = price;
  }
  if (getAvailableSeats != null) {
    queryParams['available_seats'] = getAvailableSeats;
  }
  if (carbonEmissions != null) {
    queryParams['carbon_emissions'] = carbonEmissions;
  }

  final url = Uri.http('localhost:1337', '/rides', queryParams);
  final response = await http.get(url);
  if (response.body.isNotEmpty) {
    final responseData = json.decode(response.body);
    List<Ride> rides = responseData.map<Ride>((item) {
      return Ride.fromJson(item as Map<String, dynamic>);
    }).toList();
    return rides;
  } else {
    throw Exception('No rides found');
  }
}

Future<Ride> fetchRideById(rideId) async {
  final response = await httpEnhanced.get('/rides/$rideId');
  if (response.isNotEmpty) {
    return Ride.fromJson(response as Map<String, dynamic>);
  } else {
    throw Exception('No ride found');
  }
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
    String uri = 'http://localhost:1337/users/$username';
    final response = await http.get(Uri.parse(uri));
    var user = User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return user;
  } catch (e) {
    throw Exception('No users found');
  }
}

Future<User> getCurrentUser() async {
  final response =
      await http.get(Uri.parse('http://localhost:1337/users/currentUser'));
      print(response.statusCode);
    var user = User.fromJson(jsonDecode(processResponse(response)) as Map<String, dynamic>);
    return user;
}

Future<User> postUser(user) async {
  print('test');
  String json = jsonEncode(user);
  final response = await http.post(Uri.parse('http://localhost:1337/users'),
      headers: {"Content-Type": "application/json"}, body: json);
  if (response.statusCode == 200) {
    var user = User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return user;
  } else {
    throw Exception(response.body);
  }
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

Future<User> postLogin(String username, String password) async {
  final bodyJson = jsonEncode({'password': password});
  String uri = '$baseUrl/users/$username/login';
  final response = await http.post(Uri.parse(uri),
      headers: {"Content-Type": "application/json"}, body: bodyJson);
  if (response.statusCode == 200) {
    final user =
        User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return user;
  } else if (response.statusCode == 401) {
    throw Exception('Unauthorised');
  } else {
    throw Exception("User not found");
  }
}

Future<String> postLogout(String username) async {
  String uri = '$baseUrl/users/$username/logout';
  final response = await http.post(
    Uri.parse(uri),
  );
  if (response.statusCode == 200) {
    return 'Logout successful';
  } else {
    throw Exception("Logout failed");
  }
}

Future<List> fetchLatLong(place) async {
  final response = await httpGeocode.get(
      '/search?text=$place&filter=countrycode:gb&format=json&apiKey=9ac318b7da314e00b462f8801c758396');
  final List latLong = [
    response['results'][0]['lat'],
    response['results'][0]['lon']
  ];
  return latLong;
}

Future<User?> deleteUser(user) async {
  final uri = Uri.parse("http://localhost:1337/users/${user.username}");
  final response = await http.delete(uri);

  if (response.statusCode == 200) {
    return null;
  } else {
    throw Exception("Failed to delete user account");
  }
}

Future<String?> uploadUserProfilePic(String username, String filePath) async {
  final response = await http.post(
      Uri.parse('http://localhost:1337/users/$username/image'),
      body: jsonEncode({'filePath': filePath}));
  if (response.statusCode == 201) {
    return 'good';
  } else {
    return 'bad';
  }
}

Future deleteRide(rideId) async {
  final url = Uri.parse('$baseUrl/rides/$rideId');
  final response = await http.delete(url);
  if (response.statusCode == 200) {
    return null;
  } else {
    throw Exception("Failed to delete user account");
  }
}

Future fetchDistance(waypoints) async {
  final response = await httpGeoapify.get(
      '?waypoints=$waypoints&mode=drive&apiKey=9ac318b7da314e00b462f8801c758396');
  print(response);
  final distance = response['features'][0]['properties']['distance'];
  return distance;
}

Future fetchFuelPrice(fuelType) async {
  final double fuelPrice;
  final response = await httpFuel.get(
      '/en_gb/united-kingdom/home/fuelprices/fuel_prices_data.json',
      headers: {
        "accept": '*/*',
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
      });
  if (fuelType == "PETROL") {
    fuelPrice = response["stations"][0]['prices']['E10']; //petrol price
  } else {
    fuelPrice = response["stations"][0]['prices']['B7']; //diesel price
  }
  return fuelPrice;
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

Future<Ride> postRide(ride) async {
  Uri url = Uri.parse('$baseUrl/rides');
  String json = jsonEncode(ride);
  final response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: json);
  final result = Ride.fromJson(
      jsonDecode(processResponse(response)) as Map<String, dynamic>);
  return result;
}

Future<Ride> patchRideById(rideId, patchDetails) async {
  Uri url = Uri.parse('$baseUrl/rides/$rideId');
  String bodyJson = jsonEncode(patchDetails);
  final response = await http.patch(url,
      headers: {"Content-Type": "application/json"}, body: bodyJson);
  final result = Ride.fromJson(
      jsonDecode(processResponse(response)) as Map<String, dynamic>);
  return result;
}

Future<List<Chat>> fetchMessagesByRideId(rideId, rider, isDriver) async {
  Uri url = Uri.parse('$baseUrl/rides/$rideId/messages/$rider');
  if (isDriver) {
    url = Uri.parse('$baseUrl/rides/$rideId/driverMessages/$rider');
  }
  final response = await http.get(url);
  final responseData = json.decode(processResponse(response));
  List<Chat> result = responseData.map<Chat>((item) {
    return Chat.fromJson(item as Map<String, dynamic>);
  }).toList();
  return result;
}

Future<List<Chat>> postMessageByRideId(rideId, message) async {
  Uri url = Uri.parse('$baseUrl/rides/$rideId/messages');
  String bodyJson = jsonEncode(message);
  final response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: bodyJson);
  final responseData = json.decode(processResponse(response));
  List<Chat> result = responseData.map<Chat>((item) {
    return Chat.fromJson(item as Map<String, dynamic>);
  }).toList();
  return result;
}

processResponse(Response response) {
  switch (response.statusCode) {
    case 200:
      {
        return response.body;
      }
    case 201:
      {
        return response.body;
      }
    case 400:
      {
        throw Exception('Bad Request');
      }
    case 401:
      {
        throw Exception('Unauthorised');
      }
      case 403: { }
    case 404:
      {
        throw Exception("Not Found");
      }

    default:
      {}
  }
}
