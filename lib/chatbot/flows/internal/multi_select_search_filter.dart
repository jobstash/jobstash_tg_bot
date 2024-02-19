part of '../filters_setup_flow.dart';

class _MultiSelectSearchDisplayStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterId = args?.first;

    if (filterId == null) {
      return ReactionResponse(
        text: 'Oops, something went wrong. Please try again.',
      );
    }

    return ReactionResponse(
      // editMessageId: messageContext.editMessageId,
      text: """Type position, technology or any other tag you are interested in separated by comma. 
      
_For example: "typescript, nodejs, nft"_
""",
      markdown: true,
      afterReplyUri: (_MultiSelectSearchUpdateStep).toStepUri([filterId]),
    );
  }
}

class _MultiSelectSearchUpdateStep extends FlowStep {
  _MultiSelectSearchUpdateStep(this._botApi, this._aiAssistant, this._filtersRepository);

  final TelegramBotApi _botApi;
  final AiAssistant _aiAssistant;
  final FiltersRepository _filtersRepository;

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
      final result = await _aiAssistant.parseTags(messageContext.userId.toString(), userInput);
      final tags = result?.$1;
      final unrecognizedInput = result?.$2;

      await _filtersRepository.setUserFilterValue(messageContext.userId, filterId, tags);

      // final removeTags = tags == null || tags.isEmpty;
      final responseParts = <String>[];
      if (tags != null && tags.isNotEmpty) {
        responseParts.add('Your tags are set to: ${_taggify(tags)}');
      }
      if (unrecognizedInput != null && unrecognizedInput.isNotEmpty) {
        responseParts.add('We could not recognize: ${_taggify(unrecognizedInput)}');
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
      logErrorToTelegramChannel('Failed update MultiSelectSearchFilter', error, stacktrace);
      return ReactionResponse(
        text: 'Oops, something went wrong. Please try again.',
      );
    }
  }

  String _taggify(List<String> tags) => tags.map((e) => '`${e.trim()}`').join(', ');
}
