import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Env {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
}
