import 'package:ai_assistant/src/assistant/thread_store.dart';
import 'package:openai_api/openai_api.dart';

String? threadId;

class AssistantApi {
  AssistantApi({required this.apiKey, required this.assistantId, required this.threadStore})
      : _client = OpenaiClient(config: OpenaiConfig(apiKey: apiKey));

  final OpenaiClient _client;
  final ThreadStore threadStore;

  final String apiKey;
  final String assistantId;


  Future<ImageResponse> generateImage(String prompt, bool dalle3) async {
    final result = await _client.createImage(ImageRequest(
      prompt: prompt,
      model: dalle3 ? Models.dallE3 : Models.dallE2,
      n: 1,
      style: 'vivid',
      size: dalle3 ? '1024x1024' : '256x256',
    ));
    return result;
  }

  /// Add message to existing thread or create a new thread if there's no thread yet
  Future<String?> addMessageToThread(String userId, String message) async {
    final threadId = await _getThreadId(userId);

    await _client.addThreadMessage(ChatMessage(role: ChatMessageRole.user, content: message), threadId);

    final run = await _client.createThreadRun(threadId: threadId, assistantId: assistantId);

    await _awaitRunStatusCompleted(threadId, run.id);

    final response = await _client.getThreadMessages(threadId);

    //todo there could be more then one message added to a thread as a response, return all of them
    final lastMessageModel = response.data.firstOrNull;
    print('Assistant response ${response.toString()}');


    final lastMessageText = lastMessageModel?.content.lastOrNull?.text.value;
    if (lastMessageText == null) {
      return null;
    }
    return lastMessageText;
  }

  Future<String> _getThreadId(String userId) async {
    return "thread_TaVhB0sRGElt3bWhDrgWaII5";
    // final threadId = await threadStore.getThreadId(userId);
    // if (threadId != null) {
    //   return threadId;
    // }
    //
    // final thread = await _client.createThread();
    // await threadStore.setThreadId(userId, thread.id);
    // return thread.id;
  }

  Future<void> _awaitRunStatusCompleted(String threadId, String runId) async {
    final runStatus = await _client.getThreadRunStatus(threadId: threadId, runId: runId);
    if (runStatus.status != 'completed') {
      await Future.delayed(Duration(seconds: 2));
      await _awaitRunStatusCompleted(threadId, runId);
    }
  }
}
