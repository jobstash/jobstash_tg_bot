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
      logger.d('Request url ${request.url}');

      TelegramBotApi(Config.botToken).sendMessage(Config.errorChannelId, 'Request successfully received');

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
      await logErrorToTelegramChannel(error, st);
      return Response.internalServerError(body: {'error': error.toString()});
    }
  }
}
