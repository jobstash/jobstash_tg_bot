import 'package:dotenv/dotenv.dart';

class Config {
  Config._();

  static DotEnv? _env;

  static String get botName => env('BOT_NAME');

  static String get botToken => env('BOT_TOKEN');

  static bool get isDevEnv => env('BOT_NAME') == 'JobStashDevBot';

  static String get openAiApiKey => env('OPEN_AI_API_KEY');

  static void init() {
    _env = DotEnv(includePlatformEnvironment: true)..load();
  }
}

T env<T>(String key) {
  final value = Config._env?[key];
  if (value == null) {
    throw 'Missing $key environment variable';
  } else {
    print('$key: ${value.substring(0, 5)}');
    return value as T;
  }
}
