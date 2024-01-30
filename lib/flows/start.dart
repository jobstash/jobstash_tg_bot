import 'package:chatterbox/chatterbox.dart';
import 'package:database/database.dart';

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
    return ReactionResponse(text: 'Hello ${messageContext.username}');
  }
}
