import 'package:ai_assistant/ai_assistant.dart';
import 'package:chatterbox/chatterbox.dart';
import 'package:jobstash_bot/chatbot/store/firebase_dialog_store.dart';

class DropUsersThreadFlow extends CommandFlow {
  DropUsersThreadFlow(this._store);

  final FirebaseDialogStore _store;

  @override
  String get command => 'drop_users_thread';

  @override
  List<StepFactory> get steps => [
        () => _DropUsersThreadFlowInitialStep(_store),
      ];
}

class _DropUsersThreadFlowInitialStep extends FlowStep {
  _DropUsersThreadFlowInitialStep(this._repository);

  final FirebaseDialogStore _repository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    await _repository.removeThreadId(allUsersThreadName);

    return ReactionResponse(
      text: 'Thread removed',
    );
  }
}
