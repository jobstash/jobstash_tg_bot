import 'package:chatterbox/chatterbox.dart';
import 'package:database/database.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/services/filters_repository.dart';

/// Applicable filters
/// - location
/// - salary
/// - seniority
/// - commitment
/// - head count
/// - tags
class FiltersFlow extends CommandFlow {
  FiltersFlow(this._api, this._userDao, this._filtersRepository);

  final JobStashApi _api;
  final UserDao _userDao;
  final FiltersRepository _filtersRepository;

  @override
  String get command => 'filter';

  @override
  List<StepFactory> get steps => [
        () => FiltersFlowInitialStep(_api, _userDao, _filtersRepository),
        () => _FilterDetailedStep(_api, _userDao, _filtersRepository),

      ];
}

class FiltersFlowInitialStep extends FlowStep {
  FiltersFlowInitialStep(this._api, this._userDao, this._filtersRepository);

  final JobStashApi _api;
  final UserDao _userDao;
  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filters = await _filtersRepository.getRelevantFilters();

    return ReactionResponse(
      text:
          'Hi this is JobStash.xyz bot. I will help you find a job. If you want unfiltered feed please follow (official jobstash channel)[https://t.me/jobstash].\n For filtered feed pls setup your filters',
      markdown: true,
      buttons: filters.entries
          .map(
            (e) => InlineButton(
              title: e.value.label,
              nextStepUri: (_FilterDetailedStep).toStepUri([e.key]),
            ),
          )
          .toList(),

    );
  }
}

class _FilterDetailedStep extends FlowStep {
  _FilterDetailedStep(this._api, this._userDao, this._filtersRepository);

  final JobStashApi _api;
  final UserDao _userDao;
  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterName = args?.first;
    if (filterName == null) {
      return ReactionNone();
    }

    final filters = await _api.getAllFilters(); //todo use provider

    return ReactionResponse(
      text: 'You have selected $filterName',
    );
  }
}
