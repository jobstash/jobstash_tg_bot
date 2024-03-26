import 'package:chatterbox/chatterbox.dart';
import 'package:jobstash_bot/chatbot/flows/filters_setup_flow.dart';

class StartFlow extends CommandFlow {
  StartFlow();

  @override
  String get command => 'start';

  @override
  List<StepFactory> get steps => [
        () => _StartFlowInitialStep(),
        () => _StartFlowWelcomeStep(),
      ];
}

final _welcomeText =
    'Get filtered jobstash.xyz postings. Set tags to get notified about new job offers.\nIf you are interested to get unfiltered jobs feed subscribe to [official jobstash channel](https://t.me/jobstash)';

class _StartFlowInitialStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    return ReactionRedirect(stepUri: (_StartFlowWelcomeStep).toStepUri());
  }
}

class _StartFlowWelcomeStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    return ReactionResponse(
      text: _welcomeText,
      markdown: true,
      buttons: [
        InlineButton(
          title: 'Setup filters',
          nextStepUri: (FiltersFlowInitialStep).toStepUri(),
        ),
      ],
    );
  }
}
