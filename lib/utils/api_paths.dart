
import 'package:http/browser_client.dart';

const baseHost = 'localhost:1337';
// const baseHost = 'jumpin-backend.onrender.com';
const baseUrl = 'https://$baseHost';
const geoapifyUrl = 'https://api.geoapify.com/v1/routing';
const geocodeUrl = 'https://api.geoapify.com/v1/geocode';
const fuelUrl = 'https://applegreenstores.com/fuel-prices/data.json';

final clientDefault = BrowserClient()..withCredentials = false;
final clientWithCredentials = BrowserClient()..withCredentials = true;