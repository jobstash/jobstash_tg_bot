import 'dart:io';

class Config {
  Config._();

  static String get botName => env('BOT_NAME');

  static String get botToken => env('BOT_TOKEN');

  static String get openAiApiKey => env('OPEN_AI_API_KEY');
}

T env<T>(String key) {
  final value = Platform.environment[key];
  if (value == null) {
    throw 'Missing $key environment variable';
  } else {
    print('$key: ${value.substring(0, 5)}');
    return value as T;
  }
}
