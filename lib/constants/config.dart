import 'package:flutter_dotenv/flutter_dotenv.dart';

class Configs {
  static String apiUrl = '${dotenv.env['LOCALHOST_CONFIG']}';
  static String apiServerUrl =
      '${dotenv.env['SERVER_CONFIG']}'; //SERVER_CONFIG

  void GetEnv() async {
    await dotenv.load(fileName: '.env');
  }
}
