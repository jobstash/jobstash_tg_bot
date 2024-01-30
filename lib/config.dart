import 'package:dotenv/dotenv.dart';

class Config {
  Config._();

  static DotEnv? _env;


  static String get botName => _env!['BOT_NAME']!;

  static String get botToken => _env!['BOT_TOKEN']!;

  static bool get isDevEnv => _env!['BOT_NAME'] == 'JobStashDevBot';

  static void init() {
    _env = DotEnv(includePlatformEnvironment: true)..load();
  }
}
