import 'dart:math';

import 'package:chatterbox/chatterbox.dart';
import 'package:collection/collection.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/chatbot/services/filters_repository.dart';
import 'package:jobstash_bot/chatbot/services/providers/category_filter.dart';
import 'package:jobstash_bot/chatbot/utils/args_utils.dart';
import 'package:jobstash_bot/chatbot/utils/string_utils.dart';
import 'package:jobstash_bot/common/utils/logger.dart';
import 'package:telegram_api/shared_api.dart';

part 'internal/categories_filter.dart';
part 'internal/extensions.dart';
part 'internal/tags_filter.dart';

/// Allows user to adjust filters for job offers.
class FiltersFlow extends CommandFlow {
  FiltersFlow(this._botApi, this._jobStashApi, this._repo);

  final TelegramBotApi _botApi;
  final JobStashApi _jobStashApi;

  final FiltersRepository _repo;

  @override
  String get command => 'filter';

  @override
  List<StepFactory> get steps => [
        () => FiltersFlowInitialStep(_repo),
        () => _CategoriesSelectStep(_repo),
        () => _CategoriesUpdateStep(_repo),
        () => _TagsDisplayStep(_repo),
        () => _TagsRemoveStep(_repo),
        () => _TagsUpdateStep(_jobStashApi, _repo),
        () => _TagsTryAgainStep(),
        () => _OnNewFiltersAppliedStep(),
      ];
}

class FiltersFlowInitialStep extends FlowStep {
  FiltersFlowInitialStep(this._repo);

  final FiltersRepository _repo;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final editMessageId = int.tryParse(args?.firstOrNull ?? '');

    final categories =
        await _repo.getUserFilterOptions(messageContext.userId, CategoryFilter.name) as List<String>? ?? [];
    final tags = await _repo.getUserFilterOptions(messageContext.userId, 'tags') as List<String>? ?? [];

    return ReactionResponse(
      text: """
*Select filters to update*

${_currentFiltersText(categories, tags)}
""",
      markdown: true,
      editMessageId: editMessageId,
      buttons: [
        InlineButton(
          title: 'Categories',
          nextStepUri: (_CategoriesSelectStep).toStepUri(),
        ),
        InlineButton(
          title: 'Tags',
          nextStepUri: (_TagsDisplayStep).toStepUri(),
        ),
        InlineButton(
          title: '🚀 Done 🚀',
          nextStepUri: (_OnNewFiltersAppliedStep).toStepUri(),
        ),
      ],
    );
  }

  String _currentFiltersText(List<String> categories, List<String> tags) {
    if (categories.isEmpty && tags.isEmpty) {
      return '';
    } else {
      return """      
${categories.isNotEmpty ? '*Selected Categories* : ${categories.join(', ')}' : ''}
      
${tags.isNotEmpty ? '*Selected  tags* : ${tags.join(', ')}' : ''}""";
    }
  }
}

class _OnNewFiltersAppliedStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    return ReactionResponse(
      text: 'Filters applied!\n You will now start receiving job offers based on your preferences.',
      editMessageId: messageContext.editMessageId,
    );
  }
}
