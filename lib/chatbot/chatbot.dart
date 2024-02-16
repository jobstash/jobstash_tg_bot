import 'dart:convert';
import 'dart:io';

import 'package:ai_assistant/ai_assistant.dart';
import 'package:chatterbox/chatterbox.dart';
import 'package:database/database.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/chatbot/flows/filters_setup_flow.dart';
import 'package:jobstash_bot/chatbot/flows/start_flow.dart';
import 'package:jobstash_bot/chatbot/flows/stop_flow.dart';
import 'package:jobstash_bot/chatbot/services/filters_repository.dart';
import 'package:jobstash_bot/chatbot/store/firebase_dialog_store.dart';
import 'package:jobstash_bot/common/config.dart';
import 'package:jobstash_bot/common/utils/logger.dart';
import 'package:jobstash_bot/common/utils/parsing_utils.dart';
import 'package:shelf/shelf.dart';
import 'package:telegram_api/shared_api.dart';

class ChatBot {
  Future<Response> process(Request request) async {
    try {
      Config.init();

      logger.d('Request url ${request.url}');

      final body = await parseRequestBody(request);
      logger.d('Request body ${request.url}');

      await Database.initialize();

      final userDao = Database.createUserDao();
      final dialogDao = Database.createDialogDao();
      final firebaseStore = FirebaseDialogStore(dialogDao);

      final api = JobStashApi();
      final repository = FiltersRepository(api, userDao);
      final aiAssistant = AiAssistant(Config.openAiApiKey, firebaseStore);

      final flows = <Flow>[
        StartFlow(repository),
        FiltersFlow(repository, aiAssistant),
        StopFlow(repository),
      ];

      Chatterbox(botToken: Config.botToken, flows: flows, store: firebaseStore).invokeFromWebhook(body);
      return Response.ok(
        null,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (error, st) {
      logger.e('Failed to process request', error: error, stackTrace: st);
      await TelegramBotApi(Config.botToken).sendMessage(
        Config.errorChannelId,
        'Failed to process mailer request: \n$error\n${st.toString().substring(0, 300)}',
      );
      return Response.internalServerError(body: {'error': error.toString()});
    }
  }
}

Future<Response> _proxy(Request request) async {
  try {
    HttpClient client = HttpClient();
    HttpClientRequest clientRequest = await client.openUrl(
        request.method, Uri.parse('https://0e00-169-150-196-154.ngrok-free.app${request.url.path}'));

    // Copy headers from the original request to the proxy request.
    request.headers.forEach((name, values) {
      if (name != 'host') {
        clientRequest.headers.set(name, values);
      }
    });

    // Copy the body of the original request to the proxy request.
    final requestBody = await request.read().toList();
    clientRequest.add(requestBody.expand((i) => i).toList());

    // Get the response from the proxied server.
    final clientResponse = await clientRequest.close();

    // Create a Map for the headers of the original response.
    Map<String, String> responseHeaders = {};

    // Copy headers from the proxy response to the original response.
    clientResponse.headers.forEach((name, values) {
      responseHeaders[name] = values.join(',');
    });

    // Get the body of the proxy response.
    final responseBody = await utf8.decoder.bind(clientResponse).join();

    // Return the original response with the status code, headers, and body from the proxy response.
    return Response(
      clientResponse.statusCode,
      body: responseBody,
      headers: responseHeaders,
    );
  } catch (error, st) {
    logger.e('Failed to process request', error: error, stackTrace: st);
    return Response.internalServerError(body: {'error': error.toString()});
  }
}
