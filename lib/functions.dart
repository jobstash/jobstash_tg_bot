import 'package:functions_framework/functions_framework.dart';
import 'package:jobstash_bot/chatbot/chatbot.dart';
import 'package:jobstash_bot/common/utils/logger.dart';
import 'package:jobstash_bot/mailer/mailer.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
Future<Response> function(Request request) async {
  logger.d('Request url ${request.url}');
  return switch (request.url.path) {
    'jobs' => Mailer().process(request),
    'update' => ChatBot().process(request),
    _ => Future.value(Response.notFound('Not found')),
  };
}
