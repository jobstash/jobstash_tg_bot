import 'dart:convert';

import 'package:ai_assistant/src/assistant/assistant_api.dart';
import 'package:ai_assistant/src/assistant/thread_store.dart';

typedef ImageGenerationResult = ({String aiPrompt, String postfix, String url});

const _assistantId = 'asst_2YxUelu58aspj9Sk30bs4raW';

class AiAssistant {
  AiAssistant(String apiKey, ThreadStore store)
      : _assistantApi = AssistantApi(
          apiKey: apiKey,
          assistantId: _assistantId,
          threadStore: store,
        );

  final AssistantApi _assistantApi;

  Future<(List<String>, List<String>)?> parseTags(String userId, List<String> tags) async {
    final prompt = jsonEncode({
      "user_input": tags,
    });

    final response = await _assistantApi.addMessageToThread('all_users_thread_0', prompt);

    return _parseResponse(
      response,
      (data) => (
        _parseList(data, 'recognized_tags'),
        _parseList(data, 'unrecognized_input'),
      ),
    );
  }

  List<String> _parseList(Map<String, dynamic> data, String key) =>
      (data[key] as List<dynamic>).map((e) => e.toString()).toList();
}

T _parseResponse<T>(String? response, T Function(Map<String, dynamic>) parser) {
  final json = response == null ? null : jsonDecode(response);

  if (json == null) {
    throw Exception('Empty AI prompt');
  } else if (json['error'] != null) {
    throw Exception(json['error']);
  }

  return parser(json);
}
