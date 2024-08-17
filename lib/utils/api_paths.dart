
import 'package:http/browser_client.dart';

abstract class Paths {
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: '');
}

const baseUrl = 'https://${Paths.baseUrl}';
const geoapifyUrl = 'https://api.geoapify.com/v1/routing';
const geocodeUrl = 'https://api.geoapify.com/v1/geocode';
const fuelUrl = 'https://applegreenstores.com/fuel-prices/data.json';
const licenseURL = 'https://driver-vehicle-licensing.api.gov.uk/vehicle-enquiry/v1/vehicles';
const licenseHeaders = {
        // 'x-api-key': '1gZwZ4vfFN1TbScqIP7FG4ccTa8SkB95aJN9wHBs',
        "Content-Type": 'text/plain',
      };

final clientDefault = BrowserClient()..withCredentials = false;
final clientWithCredentials = BrowserClient()..withCredentials = true;