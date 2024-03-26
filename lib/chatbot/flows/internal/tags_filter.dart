part of '../filters_setup_flow.dart';

class _TagsDisplayStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    return ReactionResponse(
      // editMessageId: messageContext.editMessageId,
      text: """Type position, technology or any other tag you are interested in separated by comma. 
      
_For example: "typescript, nodejs, nft"_
""",
      markdown: true,
      afterReplyUri: (_TagsUpdateStep).toStepUri(['tags']),
    );
  }
}

class _TagsUpdateStep extends FlowStep {
  _TagsUpdateStep(this._botApi, this._jobStashApi, this._repo);

  final TelegramBotApi _botApi;
  final JobStashApi _jobStashApi;
  final FiltersRepository _repo;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterId = args?.firstOrNull;
    final userInput = messageContext.text?.split(',');

    //todo if user input clear, then remove tags
    _botApi.sendMessage(messageContext.chatId, 'Processing your tags...');

    if (userInput == null || filterId == null) {
      return ReactionResponse(
        text: 'Oops, something went wrong. Please try again.',
      );
    }

    try {
      final result = await _jobStashApi.matchTags(userInput);
      final data = result.data;

      if (!result.success || data == null) {
        return ReactionResponse(text: result.message ?? 'Oops, something went wrong. Please try again.');
      }

      final tags = data.recognizedTags;
      final unrecognizedInput = data.unrecognizedTags;

      await _repo.setUserFilterValue(messageContext.userId, filterId, tags);

      // final removeTags = tags == null || tags.isEmpty;
      final responseParts = <String>[];
      if (tags != null && tags.isNotEmpty) {
        responseParts.add('Your tags are set to: ${_taggify(tags)}');
      }
      if (unrecognizedInput != null && unrecognizedInput.isNotEmpty) {
        responseParts.add('We could not recognize: ${_taggify(unrecognizedInput)}');
      }

      if (responseParts.isEmpty) {
        return ReactionRedirect(stepUri: (_MultiSelectTryAgainStep).toStepUri());
      }

      return ReactionComposed(responses: [
        // if (!removeTags)
        ReactionResponse(
          text: responseParts.join('\n'),
          markdown: true,
        ),
        // if (removeTags) ReactionResponse(text: 'Tags removed'),
        ReactionRedirect(
          stepUri: (_OnNewFiltersAppliedStep).toStepUri([filterId]),
        ),
      ]);
    } catch (error, stacktrace) {
      logErrorToTelegramChannel('Failed update TagsFilter', error, stacktrace);
      return ReactionResponse(
        text: 'Oops, something went wrong. Please try again.',
      );
    }
  }

  String _taggify(List<String> tags) => tags.map((e) => '`${e.trim()}`').join(', ');
}

class _MultiSelectTryAgainStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    return ReactionComposed(responses: [
      ReactionResponse(
        text: "Could not recognize your tags. Please to spell in different a way or use different tags.",
      ),
    ]);
  }
}
