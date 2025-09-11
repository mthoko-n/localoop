import 'package:flutter_dotenv/flutter_dotenv.dart';

class NetworkHelper {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:8000';

  static Uri buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters);
  }
}
