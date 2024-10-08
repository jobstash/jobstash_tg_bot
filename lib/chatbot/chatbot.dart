import 'package:chatterbox/chatterbox.dart';
import 'package:database/database.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/chatbot/flows/admin/add_community.dart';
import 'package:jobstash_bot/chatbot/flows/admin/stats_flow.dart';
import 'package:jobstash_bot/chatbot/flows/user/filters_setup_flow.dart';
import 'package:jobstash_bot/chatbot/flows/user/start_flow.dart';
import 'package:jobstash_bot/chatbot/flows/user/stop_flow.dart';
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

      final body = await parseRequestBody(request);
      logger.d('Request body ${request.url}');

      await Database.initialize(Config.googleProjectId);

      final userDao = Database.createFiltersDao();
      final dialogDao = Database.createDialogDao();
      final firebaseStore = FirebaseDialogStore(dialogDao);

      final api = JobStashApi();
      final repository = FiltersRepository(userDao);
      final botApi = TelegramBotApi(Config.botToken);

      final flows = <Flow>[
        StartFlow(),
        FiltersFlow(botApi, api, repository),
        StopFlow(repository),

        // Admin
        StatsFlow(repository),
        AddCommunityFlow(repository, botApi),
      ];

      Chatterbox(botToken: Config.botToken, flows: flows, store: firebaseStore).invokeFromWebhook(body);
      return Response.ok(
        null,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (error, st) {
      logger.e('Failed to process request', error: error, stackTrace: st);
      await logErrorToTelegramChannel('Failed process chatbot request ${request.url}', error, st);
      return Response.internalServerError(body: {'error': error.toString()});
    }
  }
}
