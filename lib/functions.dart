import 'dart:convert';

import 'package:chatterbox/chatterbox.dart';
import 'package:database/database.dart';
import 'package:functions_framework/functions_framework.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/config.dart';
import 'package:jobstash_bot/flows/filters_setup_flow.dart';
import 'package:jobstash_bot/flows/start.dart';
import 'package:jobstash_bot/services/filters_repository.dart';
import 'package:jobstash_bot/store/firebase_dialog_store.dart';
import 'package:jobstash_bot/utils/logger.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
Future<Response> function(Request request) async {
  try {
    Config.init();

    logger.d('Request url ${request.url}');

    final body = await parseRequestBody(request);
    logger.d('Request body ${request.url}');

    await Database.initialize();

    final userDao = Database.createUserDao();
    final dialogDao = Database.createDialogDao();
    final dialogStore = FirebaseDialogStore(dialogDao);

    final api = JobStashApi();
    final filtersRepository = FiltersRepository(api, userDao);

    final flows = <Flow>[
      StartFlow(userDao),
      FiltersFlow(userDao, filtersRepository),
    ];

    Chatterbox(botToken: Config.botToken, flows: flows, store: dialogStore).invokeFromWebhook(body);
    return Response.ok(
      null,
      headers: {'Content-Type': 'application/json'},
    );
  } catch (error, st) {
    logger.e('Failed to process request', error: error, stackTrace: st);
    return Response.internalServerError(body: {'error': error.toString()});
  }
}

Future<Map<String, dynamic>> parseRequestBody(Request request) async {
  final bodyBytes = await request.read().toList();
  final bodyString = utf8.decode(bodyBytes.expand((i) => i).toList());
  final jsonObject = jsonDecode(bodyString) as Map<String, dynamic>;

  return jsonObject;
}
