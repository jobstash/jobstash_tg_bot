import 'package:ai_assistant/ai_assistant.dart';
import 'package:chatterbox/chatterbox.dart';
import 'package:collection/collection.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/chatbot/services/filters_repository.dart';
import 'package:jobstash_bot/common/utils/logger.dart';
import 'package:telegram_api/shared_api.dart';

part 'internal/extensions.dart';

part 'internal/multi_select_filter.dart';

part 'internal/multi_select_search_filter.dart';

part 'internal/range_filter.dart';

/// Allows user to adjust filters for job offers.
class FiltersFlow extends CommandFlow {
  FiltersFlow(this._botApi, this._filtersRepository, this._aiAssistant);

  final TelegramBotApi _botApi;
  final AiAssistant _aiAssistant;
  final FiltersRepository _filtersRepository;

  @override
  String get command => 'filter';

  @override
  List<StepFactory> get steps => [
        () => FiltersFlowInitialStep(_filtersRepository),
        () => FilterDetailedStep(_filtersRepository),
        () => _MultiSelectFilterDisplayStep(_filtersRepository),
        () => _MultiSelectFilterUpdateStep(_filtersRepository),
        () => _RangeFilterDisplayStep(_filtersRepository),
        () => _RangeFilterUpdateStep(_filtersRepository),
        () => _MultiSelectSearchDisplayStep(),
        () => _MultiSelectSearchUpdateStep(_botApi, _aiAssistant, _filtersRepository),
        () => _MultiSelectTryAgainStep(),
        () => _OnNewFiltersAppliedStep(),
      ];
}

class FiltersFlowInitialStep extends FlowStep {
  FiltersFlowInitialStep(this._filtersRepository);

  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    // final filters = await _filtersRepository.getRelevantFilters();
    // final editMessageId = int.tryParse(args.secondOrNull ?? '');

    // final userFilters = await _filtersRepository.getFilters(messageContext.userId);

    return ReactionRedirect(
      stepUri: (FilterDetailedStep).toStepUri(['tags']),
    );

    // return ReactionResponse(
    //   text: 'Please select filter you want to adjust.',
    //   markdown: true,
    //   editMessageId: editMessageId,
    //   buttons: [
    //     ...filters.entries.map(
    //       (filter) {
    //         final isFilterSet = false; //todo userFilters?.containsKey(filter.key) == true;
    //         return InlineButton(
    //           title: '${filter.value.label} ${isFilterSet ? _getEmojiByFilter(filter.value.paramKey) : ''}',
    //           nextStepUri: (FilterDetailedStep).toStepUri([filter.key]),//
    //         );
    //       },
    //     ),
    //     InlineButton(
    //       title: '🚀 Done 🚀',
    //       nextStepUri: (_OnNewFiltersAppliedStep).toStepUri(),
    //     ),
    //   ],
    // );
  }

  String _getEmojiByFilter(String? filter) {
    switch (filter) {
      case 'location':
        return '📍';
      case 'salary':
        return '💰';
      case 'seniority':
        return '👴';
      case 'commitment':
        return '🤝';
      case 'head_count':
        return '👥';
      case 'tags':
        return '🏷️';
      default:
        return '';
    }
  }
}

class FilterDetailedStep extends FlowStep {
  FilterDetailedStep(this._filtersRepository);

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

    switch (filter.kind) {
      case FilterKind.multiSelect:
        return ReactionRedirect(stepUri: (_MultiSelectFilterDisplayStep).toStepUri([filterId]));
      case FilterKind.range:
        return ReactionRedirect(stepUri: (_RangeFilterDisplayStep).toStepUri([filterId]));
      case FilterKind.multiSelectWithSearch:
        if ((filter.options?.length ?? 0) > 20) {
          return ReactionRedirect(stepUri: (_MultiSelectSearchDisplayStep).toStepUri([filterId]));
        } else {
          return ReactionRedirect(stepUri: (_MultiSelectFilterDisplayStep).toStepUri([filterId]));
        }
      // case FilterKind.singleSelect:
      //   return ReactionRedirect(stepUri: (_AdjustSingleSelectFilterStep).toStepUri([filterId]));
      //   return ReactionRedirect(stepUri: (_AdjustMultiSelectWithSearchFilterStep).toStepUri([filterId]));

      default:
        return ReactionNone();
    }
  }
}

class _OnNewFiltersAppliedStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    return ReactionResponse(
        text: """Filters applied! You will now start receiving job offers based on your tag preferences.

If you want to stop this bot from sending you job offers, just type /stop.
You can adjust your tag filters at any time by typing /filter.
"""
        // editMessageId: messageContext.editMessageId,
        );
  }
}
