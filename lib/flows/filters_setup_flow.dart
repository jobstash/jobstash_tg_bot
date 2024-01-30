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
  FiltersFlow(this._userDao, this._filtersRepository);

  final UserDao _userDao;
  final FiltersRepository _filtersRepository;

  @override
  String get command => 'filter';

  @override
  List<StepFactory> get steps => [
        () => FiltersFlowInitialStep(_userDao, _filtersRepository),
        () => _FilterDetailedStep(_userDao, _filtersRepository),
        () => _MultiSelectFilterDisplayStep(_userDao, _filtersRepository),
        () => _MultiSelectFilterToggleStep(_userDao, _filtersRepository),
      ];
}

class FiltersFlowInitialStep extends FlowStep {
  FiltersFlowInitialStep(this._userDao, this._filtersRepository);

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
  _FilterDetailedStep(this._userDao, this._filtersRepository);

  final UserDao _userDao;
  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterKey = args?.first;
    if (filterKey == null) {
      return ReactionNone();
    }

    final filters = await _filtersRepository.getRelevantFilters();

    final Filter? filter = filters[filterKey];
    if (filter == null) {
      return ReactionResponse(text: 'Something went wrong.\n\nFilter $filterKey not found');
    }

    print('filter: $filter');

    switch (filter.kind) {
      case FilterKind.multiSelect:
        return ReactionRedirect(stepUri: (_MultiSelectFilterDisplayStep).toStepUri([filterKey]));
      default:
        return ReactionNone();
      // case FilterKind.range:
      //   return ReactionRedirect(stepUri: (_AdjustRangeFilterStep).toStepUri([filterKey]));
      // case FilterKind.singleSelect:
      //   return ReactionRedirect(stepUri: (_AdjustSingleSelectFilterStep).toStepUri([filterKey]));
      // case FilterKind.multiSelectWithSearch:
      //   return ReactionRedirect(stepUri: (_AdjustMultiSelectWithSearchFilterStep).toStepUri([filterKey]));
    }
  }
}

class _MultiSelectFilterDisplayStep extends FlowStep {
  _MultiSelectFilterDisplayStep(this._userDao, this._filtersRepository);

  final UserDao _userDao;
  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterKey = args?.first;
    final secondArg = args?.elementAtOrNull(1);
    final editMessageId = secondArg != null ? int.tryParse(secondArg) : messageContext.editMessageId;

    if (filterKey == null) {
      return ReactionNone();
    }

    final filters = await _filtersRepository.getRelevantFilters();

    final Filter? filter = filters[filterKey];
    if (filter == null) {
      return ReactionResponse(text: 'Something went wrong.\n\nFilter $filterKey not found');
    }

    final selectedOptions = await _filtersRepository.getUserFilterOptions(messageContext.userId, filterKey);

    return ReactionResponse(
      text: filter.label,
      editMessageId: editMessageId,
      buttons: filter.options
              ?.map((option) {
                final isSelected = selectedOptions?.contains(option.toString()) == true;
                return InlineButton(
                  title: '${option.toString()} ${isSelected ? '✅' : ''}',
                  nextStepUri: (_MultiSelectFilterToggleStep).toStepUri([filterKey, option]),
                );
              })
              .toList()
              .withBackButton((_FilterDetailedStep).toStepUri([filterKey])) ??
          [],
    );
  }
}

class _MultiSelectFilterToggleStep extends FlowStep {
  _MultiSelectFilterToggleStep(this._userDao, this._filtersRepository);

  final UserDao _userDao;
  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterId = args?.firstOrNull;
    final option = args?.lastOrNull;
    if (filterId == null || option == null) {
      return ReactionNone();
    }

    await _filtersRepository.toggleUserFilterOption(messageContext.userId, filterId, option);

    return ReactionRedirect(stepUri: (_MultiSelectFilterDisplayStep).toStepUri([filterId]));
  }
}

extension on FiltersRepository {
  Future<Reaction> withFilters(
    String? filterKey,
    Future<Reaction> Function(Filter filter, Map<String, Filter>) action,
  ) async {
    if (filterKey == null) {
      return ReactionResponse(text: 'Something went wrong.\n\nFilter $filterKey not found');
    }

    final filters = await getRelevantFilters();

    final Filter? filter = filters[filterKey];
    if (filter == null) {
      return ReactionResponse(text: 'Something went wrong.\n\nFilter for $filterKey not found');
    }

    return action(filter, filters);
  }
}

extension on List<InlineButton> {
  List<InlineButton> withBackButton(String stepUri) {
    return [
      ...this,
      InlineButton(
        title: 'Back',
        nextStepUri: stepUri,
      ),
    ];
  }
}
