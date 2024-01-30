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
        () => _StartFlowInitialStep(userDao),
      ];
}

class _StartFlowInitialStep extends FlowStep {
  _StartFlowInitialStep(this.userDao);

  final UserDao userDao;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    return ReactionResponse(
      text:
          'Hi this is JobStash.xyz bot. I will help you find a job. If you want unfiltered feed please follow (official jobstash channel)[https://t.me/jobstash].\n For filtered feed pls setup your filters',
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
