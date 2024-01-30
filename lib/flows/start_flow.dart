import 'package:chatterbox/chatterbox.dart';
import 'package:jobstash_bot/flows/filters_setup_flow.dart';
import 'package:jobstash_bot/services/filters_repository.dart';

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
    'Hi this is JobStash.xyz bot. I will help you find a job. If you want unfiltered feed please follow (official jobstash channel)[https://t.me/jobstash].\n For filtered feed pls setup your filters';

class _StartFlowInitialStep extends FlowStep {
  _StartFlowInitialStep(this._repository);

  final FiltersRepository _repository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final isExistingUser = await _repository.isUserExists(messageContext.userId);
    if (!isExistingUser) {
      return ReactionRedirect(stepUri: (_StartFlowWelcomeStep).toStepUri());
    }

    final feedStopped = await _repository.isFeedStopped(messageContext.userId);
    if (feedStopped) {
      await _repository.setFeedStopped(messageContext.userId, false);
      return ReactionResponse(text: 'Welcome back! Your feed is now active again.');
    }

    return ReactionResponse(text: 'To adjust your filters send /filter command.');
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
          title: 'Setup filters',
          nextStepUri: (_OnSetupFiltersSelected).toStepUri(),
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
