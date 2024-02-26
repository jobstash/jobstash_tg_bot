import 'dart:math';

import 'package:jobstash_bot/common/config.dart';
import 'package:logger/logger.dart';
import 'package:telegram_api/shared_api.dart';

final logger = Logger(
  filter: DevelopmentFilter(),
  printer: PrettyPrinter(),
  output: null, // Use the default LogOutput (-> send everything to console)
);

Future<void> logErrorToTelegramChannel(String message, Object error, StackTrace st) async {
  try {
    final stacktrace = st.toString();
    final errorDescription = error;
    await TelegramBotApi(Config.botToken).sendMessage(
      Config.errorChannelId,
      '$message\n$errorDescription\n${stacktrace.substring(0, min(stacktrace.length, 300))}',
    );
  } catch (error, st) {
    logger.e('Failed to log error to telegram channel', error: error, stackTrace: st);
  }
}

Future<void> logToTelegramChannel(String message) async {
  try {
    await TelegramBotApi(Config.botToken).sendMessage(Config.errorChannelId, message);
  } catch (error, st) {
    logger.e('Failed to log error to telegram channel', error: error, stackTrace: st);
  }
}