import 'dart:convert';
import 'dart:async';
import 'package:fe/utils/api_paths.dart';
import 'package:fe/utils/process_api_response.dart';
import 'package:fe/classes/ride_class.dart';
import 'package:fe/classes/chat_class.dart';

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
  final response = await clientWithCredentials.get(url);
  List<Ride> result = json.decode(processResponse(response)).map<Ride>((item) {
    return Ride.fromJson(item as Map<String, dynamic>);
  }).toList();
  return result;
}

Future<Ride> fetchRideById(rideId) async {
  Uri url = Uri.parse('$baseUrl/rides/$rideId');
  final response = await clientWithCredentials.get(url);
  final result = Ride.fromJson(json.decode(processResponse(response)) as Map<String, dynamic>);
  return result;
}

Future<List<Chat>> fetchMessagesByRideId(rideId, rider, isDriver) async {
  Uri url = Uri.parse('$baseUrl/rides/$rideId/messages/$rider');
  if (isDriver) {
    url = Uri.parse('$baseUrl/rides/$rideId/driverMessages/$rider');
  }
  final response = await clientWithCredentials.get(url);
  final responseData = json.decode(processResponse(response));
  List<Chat> result = responseData.map<Chat>((item) {
    return Chat.fromJson(item as Map<String, dynamic>);
  }).toList();
  return result;
}

Future<List<Chat>> postMessageByRideId(rideId, message) async {
  Uri url = Uri.parse('$baseUrl/rides/$rideId/messages');
  String bodyJson = jsonEncode(message);
  final response = await clientWithCredentials.post(url,
      headers: {"Content-Type": "application/json"}, body: bodyJson);
  final responseData = json.decode(processResponse(response));
  List<Chat> result = responseData.map<Chat>((item) {
    return Chat.fromJson(item as Map<String, dynamic>);
  }).toList();
  return result;
}

Future<List> fetchLatLong(place) async {
  final url = Uri.parse('$geocodeUrl/search?text=$place&filter=countrycode:gb&format=json&apiKey=9ac318b7da314e00b462f8801c758396');
  final response = await clientDefault.get(url);
  final result = json.decode(processResponse(response));
  final List latLong = [
    result['results'][0]['lat'],
    result['results'][0]['lon']
  ];
  return latLong;
}

Future<Ride> postRide(ride) async {
  Uri url = Uri.parse('$baseUrl/rides');
  String json = jsonEncode(ride);
  final response = await clientWithCredentials.post(url,
      headers: {"Content-Type": "application/json"}, body: json);
  final result = Ride.fromJson(
      jsonDecode(processResponse(response)) as Map<String, dynamic>);
  return result;
}

Future<Ride> patchRideById(rideId, patchDetails) async {
  Uri url = Uri.parse('$baseUrl/rides/$rideId');
  String bodyJson = jsonEncode(patchDetails);
  final response = await clientWithCredentials.patch(url,
      headers: {"Content-Type": "application/json"}, body: bodyJson);
  final result = Ride.fromJson(
      jsonDecode(processResponse(response)) as Map<String, dynamic>);
  return result;
}

Future<void> deleteRide(rideId) async {
  Uri url = Uri.parse('$baseUrl/rides/$rideId');
  final response = await clientWithCredentials.delete(url);
  processResponse(response);
}

Future fetchDistance(waypoints) async {
  final url = Uri.parse('$geoapifyUrl?waypoints=$waypoints&mode=drive&apiKey=9ac318b7da314e00b462f8801c758396');
  final response = await clientDefault.get(url);
  final result = json.decode(processResponse(response));
  final distance = result['features'][0]['properties']['distance'];
  return distance;
}

Future fetchFuelPrice(fuelType) async {
  final double fuelPrice;
  final url = Uri.parse(fuelUrl);
  final Map<String, String> requestHeaders = {
        "accept": '*/*',
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
      };
  final response = await clientDefault.get(url,headers: requestHeaders);
  final result = json.decode(processResponse(response));
  if (fuelType == "PETROL") {
    fuelPrice = result["stations"][0]['prices']['E10']; //petrol price
  } else {
    fuelPrice = result["stations"][0]['prices']['B7']; //diesel price
  }
  return fuelPrice;
}
