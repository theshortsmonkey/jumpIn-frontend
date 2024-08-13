import 'dart:convert';
import 'dart:async';
import "package:http/http.dart" as http;
import 'package:enhanced_http/enhanced_http.dart';
import 'package:fe/auth_provider.dart';
import 'package:fe/classes/ride_class.dart';
import 'package:fe/classes/chat_class.dart';

EnhancedHttp httpEnhanced = EnhancedHttp(
  baseURL: 'https://localhost:1337',
  );
// EnhancedHttp httpEnhanced = EnhancedHttp(baseURL: 'https://jumpin-backend.onrender.com');
EnhancedHttp httpGeoapify =
    EnhancedHttp(baseURL: 'https://api.geoapify.com/v1/routing');
EnhancedHttp httpGeocode =
    EnhancedHttp(baseURL: 'https://api.geoapify.com/v1/geocode');
EnhancedHttp httpFuel = EnhancedHttp(baseURL: 'https://www.bp.com');

const baseHost = 'localhost:1337';
const baseUrl = 'https://$baseHost';
// const baseHost = 'jumpin-backend.onrender.com';
// const baseUrl = 'https://$baseHost';
const geoapifyUrl = 'https://api.geoapify.com/v1/routing';

Future<ActiveSession> getCurrentSession() async {
  Uri url = Uri.parse('$baseUrl/users/currentUser');
  final response = await http.get(url);
  final user = ActiveSession.fromJson(
      jsonDecode(processResponse(response)) as Map<String, dynamic>);
  return user;
}

Future<List<Ride>> fetchRides(
    {String? driverUsername,
    String? to,
    String? from,
    String? getDateTime,
    int? price,
    int? getAvailableSeats,
    int? carbonEmissions}) async {
  final queryParams = <String, dynamic>{};
  if (driverUsername?.isNotEmpty ?? false) {
    queryParams['driver_username'] = driverUsername;
  }
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

  final url = Uri.https(baseHost, '/rides', queryParams);
  final response = await http.get(url);
  List<Ride> result = json.decode(processResponse(response)).map<Ride>((item) {
    return Ride.fromJson(item as Map<String, dynamic>);
  }).toList();
  return result;
}

Future<Ride> fetchRideById(rideId) async {
  final response = await httpEnhanced.get('/rides/$rideId');
  if (response.isNotEmpty) {
    return Ride.fromJson(response as Map<String, dynamic>);
  } else {
    throw Exception('No ride found');
  }
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

Future<List> fetchLatLong(place) async {
  final response = await httpGeocode.get(
      '/search?text=$place&filter=countrycode:gb&format=json&apiKey=9ac318b7da314e00b462f8801c758396');
  final List latLong = [
    response['results'][0]['lat'],
    response['results'][0]['lon']
  ];
  return latLong;
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

Future<void> deleteRide(rideId) async {
  Uri url = Uri.parse('$baseUrl/rides/$rideId');
  final response = await http.delete(url);
  processResponse(response);
}

Future fetchDistance(waypoints) async {
  final response = await httpGeoapify.get(
      '?waypoints=$waypoints&mode=drive&apiKey=9ac318b7da314e00b462f8801c758396');
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
    case 403:
      {
        throw Exception('Login session not active');
      }
    case 404:
      {
        throw Exception("Not Found");
      }
    default:
      {
        throw Exception("Un-handled response");
      }
  }
}