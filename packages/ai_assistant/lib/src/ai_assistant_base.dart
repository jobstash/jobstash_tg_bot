import 'package:dart_openai/dart_openai.dart';

///gpt-3.5-turbo-0613 and gpt-4-0613
const _model = "gpt-3.5-turbo";

class AiAssistant {
  AiAssistant._(String apiKey) {
    print('AiAssistant create with $apiKey');
    OpenAI.apiKey = apiKey;
  }

  static var _initialized = false;
  static late final AiAssistant instance;

  String process(String? text) {
    return 'Ai response to $text';
  }

  static Future<void> init(String apiKey) async {
    if (!_initialized) {
      instance = AiAssistant._(apiKey);
      _initialized = true;
    }
  }

  Future<String?> sendMessage(String text) async {
    final result = await OpenAI.instance.chat.create(
      model: _model,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: text,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );

    return result.choices.firstOrNull?.message.content;
  }

  Future<String?> createImage(String prompt) async {
    final result = await OpenAI.instance.image.create(
      prompt: '$prompt; Simple, cartoonish, like in study books',
      n: 1,
      size: OpenAIImageSize.size256,
      responseFormat: OpenAIImageResponseFormat.url,
    );

    return result.data.firstOrNull?.url;
  }
}
