
import 'package:enhanced_http/enhanced_http.dart';

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
const geocodeUrl = 'https://api.geoapify.com/v1/geocode';