
import 'package:http/http.dart';

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
