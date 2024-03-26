import 'dart:math';

import 'package:chatterbox/chatterbox.dart';
import 'package:collection/collection.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/chatbot/services/filters_repository.dart';
import 'package:jobstash_bot/chatbot/services/providers/category_filter.dart';
import 'package:jobstash_bot/chatbot/utils/args_utils.dart';
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
        () => FiltersFlowInitialStep(),
        () => _CategoriesSelectStep(_repo),
        () => _CategoriesUpdateStep(_repo),
        () => _TagsDisplayStep(),
        () => _TagsUpdateStep(_botApi, _jobStashApi, _repo),
      ];
}

class FiltersFlowInitialStep extends FlowStep {
  FiltersFlowInitialStep();

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final editMessageId = int.tryParse(args?.firstOrNull ?? '');

    return ReactionResponse(
      text: 'Please select filter you want to adjust.',
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
