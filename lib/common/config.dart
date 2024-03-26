import 'dart:io';

class Config {
  Config._();

  static final int errorChannelId = -1001956242482;

  static String get botName => env('BOT_NAME');

  static String get botToken => env('BOT_TOKEN');

  static bool get isDevEnv => env('BOT_NAME') == 'JobStashDevBot';

  static String get openAiApiKey => env('OPEN_AI_API_KEY');

  static const List<int> admins = [25954567, 1659134542];

  static bool checkIsAdmin(int userId) => admins.contains(userId);
}

T env<T>(String key) {
  final value = Platform.environment[key];
  if (value == null) {
    throw 'Missing $key environment variable';
  } else {
    return value as T;
  }
}
