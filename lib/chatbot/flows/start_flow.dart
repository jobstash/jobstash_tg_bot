import 'package:chatterbox/chatterbox.dart';
import 'package:jobstash_bot/chatbot/flows/filters_setup_flow.dart';
import 'package:jobstash_bot/chatbot/services/filters_repository.dart';

class StartFlow extends CommandFlow {
  StartFlow(this._repository);

  final FiltersRepository _repository;

  @override
  String get command => 'start';

  @override
  List<StepFactory> get steps => [
        () => _StartFlowInitialStep(_repository),
        () => _StartFlowWelcomeStep(_repository),
        () => _OnSetupFiltersSelected(),
      ];
}

final _welcomeText =
    'Get filtered jobstash.xyz postings. Set tags to get notified about new job offers.\nIf you are interested to get unfiltered jobs feed subscribe to [official jobstash channel](https://t.me/jobstash)';

class _StartFlowInitialStep extends FlowStep {
  _StartFlowInitialStep(this._repository);

  final FiltersRepository _repository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final isExistingUser = await _repository.isUserExists(messageContext.userId);
    // if (!isExistingUser) {
    return ReactionRedirect(stepUri: (_StartFlowWelcomeStep).toStepUri());
    // }

    // final feedStopped = await _repository.isFeedStopped(messageContext.userId);
    // if (feedStopped) {
    //   await _repository.setFeedStopped(messageContext.userId, false);
    //   return ReactionResponse(text: 'Welcome back! Your feed is now active again.');
    // }
    //
    // return ReactionResponse(text: 'To adjust your filters send /filter command.');
  }
}

class _StartFlowWelcomeStep extends FlowStep {
  _StartFlowWelcomeStep(this._repository);

  final FiltersRepository _repository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    return ReactionResponse(
      text: _welcomeText,
      markdown: true,
      buttons: [
        InlineButton(
          title: 'Setup tags',
          // nextStepUri: (SetTagsFlowInitialStep).toStepUri(),
          nextStepUri: (FilterDetailedStep).toStepUri(['tags']),
        ),
      ],
    );
  }
}

class _OnSetupFiltersSelected extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    return ReactionComposed(responses: [
      ReactionResponse(
        text: _welcomeText,
        markdown: true,
        editMessageId: messageContext.editMessageId,
      ),
      ReactionRedirect(
        stepUri: (FiltersFlowInitialStep).toStepUri(),
      ),
    ]);
  }
}
