
import 'package:http/browser_client.dart';

abstract class Paths {
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: '');
}

const baseUrl = 'https://${Paths.baseUrl}';
const geoapifyUrl = 'https://api.geoapify.com/v1/routing';
const geocodeUrl = 'https://api.geoapify.com/v1/geocode';
const fuelUrl = 'https://applegreenstores.com/fuel-prices/data.json';

final clientDefault = BrowserClient()..withCredentials = false;
final clientWithCredentials = BrowserClient()..withCredentials = true;