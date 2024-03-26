import 'package:chatterbox/chatterbox.dart';
import 'package:jobstash_bot/chatbot/flows/admin/admin_base_flow.dart';
import 'package:jobstash_bot/chatbot/services/filters_repository.dart';

class StatsFlow extends CommandFlow {
  StatsFlow(this._repo);

  final FiltersRepository _repo;

  @override
  String get command => 'stats';

  @override
  List<StepFactory> get steps => [
        () => MenuStep(),
        () => _UserCountsStep(_repo),
      ];
}

class MenuStep extends AdminFlowStep {
  @override
  Future<Reaction> handleAdmin(MessageContext messageContext, [List<String>? args]) async {
    return ReactionResponse(
      text: 'Select an option',
      buttons: [
        InlineButton(
          title: 'Get Users Count',
          nextStepUri: (_UserCountsStep).toStepUri(),
        ),
      ],
    );
  }
}

class _UserCountsStep extends AdminFlowStep {
  _UserCountsStep(this._repo);

  final FiltersRepository _repo;

  @override
  Future<Reaction> handleAdmin(MessageContext messageContext, [List<String>? args]) async {
    final usersCount = await _repo.getUsersCount();
    return ReactionResponse(
      text: 'Total users: $usersCount',
    );
  }
}
