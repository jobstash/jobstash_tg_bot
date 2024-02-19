import 'package:chatterbox/chatterbox.dart';
import 'package:jobstash_bot/chatbot/services/filters_repository.dart';

class StopFlow extends CommandFlow {
  StopFlow(this._repository);

  final FiltersRepository _repository;

  @override
  String get command => 'stop';

  @override
  List<StepFactory> get steps => [
        () => _StopFlowInitialStep(_repository),
      ];
}

class _StopFlowInitialStep extends FlowStep {

  _StopFlowInitialStep(this._repository);

  final FiltersRepository _repository;
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    await _repository.removeFilters(messageContext.userId, true);

    return ReactionResponse(
      text:
          'No postings no more! Just send /start command to start receiving postings again.\nYou can adjust your filters by sending /filter command.',
    );
  }
}
