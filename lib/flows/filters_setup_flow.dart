import 'package:chatterbox/chatterbox.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/services/filters_repository.dart';
import 'package:collection/collection.dart';
import 'package:jobstash_bot/utils/args_utils.dart';

part 'internal/extensions.dart';

part 'internal/multi_select_filter.dart';

part 'internal/range_filter.dart';

/// Applicable filters
/// - location
/// - salary
/// - seniority
/// - commitment
/// - head count
/// - tags
class FiltersFlow extends CommandFlow {
  FiltersFlow(this._filtersRepository);

  final FiltersRepository _filtersRepository;

  @override
  String get command => 'filter';

  @override
  List<StepFactory> get steps => [
        () => FiltersFlowInitialStep(_filtersRepository),
        () => _FilterDetailedStep(_filtersRepository),
        () => _MultiSelectFilterDisplayStep(_filtersRepository),
        () => _MultiSelectFilterUpdateStep(_filtersRepository),
        () => _RangeFilterDisplayStep(_filtersRepository),
        () => _RangeFilterUpdateStep(_filtersRepository),
      ];
}

class FiltersFlowInitialStep extends FlowStep {
  FiltersFlowInitialStep(this._filtersRepository);

  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filters = await _filtersRepository.getRelevantFilters();
    final editMessageId = int.tryParse(args.secondOrNull ?? '');

    return ReactionResponse(
      text: 'Please select filter you want to adjust.',
      markdown: true,
      editMessageId: editMessageId,
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
  _FilterDetailedStep(this._filtersRepository);

  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {

    final filterId = args?.first;
    if (filterId == null) {
      return ReactionNone();
    }

    final filters = await _filtersRepository.getRelevantFilters();

    final Filter? filter = filters[filterId];
    if (filter == null) {
      return ReactionResponse(text: 'Something went wrong.\n\nFilter $filterId not found');
    }

    print('filter: $filter');

    switch (filter.kind) {
      case FilterKind.multiSelectWithSearch:
      case FilterKind.multiSelect:
        return ReactionRedirect(stepUri: (_MultiSelectFilterDisplayStep).toStepUri([filterId]));
      case FilterKind.range:
        return ReactionRedirect(stepUri: (_RangeFilterDisplayStep).toStepUri([filterId]));
      // case FilterKind.singleSelect:
      //   return ReactionRedirect(stepUri: (_AdjustSingleSelectFilterStep).toStepUri([filterId]));
      //   return ReactionRedirect(stepUri: (_AdjustMultiSelectWithSearchFilterStep).toStepUri([filterId]));

      default:
        return ReactionNone();
    }
  }
}
