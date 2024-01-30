import 'package:chatterbox/chatterbox.dart';
import 'package:database/database.dart';
import 'package:jobstash_bot/flows/filters_setup_flow.dart';

class StartFlow extends CommandFlow {
  StartFlow(this.userDao);

  final UserDao userDao;

  @override
  String get command => 'start';

  @override
  List<StepFactory> get steps => [
        () => _StartFlowInitialStep(),
        () => _OnSetupFiltersSelected(),
      ];
}

final _welcomeText =
    'Hi this is JobStash.xyz bot. I will help you find a job. If you want unfiltered feed please follow (official jobstash channel)[https://t.me/jobstash].\n For filtered feed pls setup your filters';

class _StartFlowInitialStep extends FlowStep {
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
