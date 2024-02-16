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
      editMessageId: messageContext.editMessageId,
      text: """Please type tags/ technologies you are interested in separated by comma or type *Back* to go back.
_Example: Kotlin, Java, Python_ 
""",
      markdown: true,
      afterReplyUri: (_MultiSelectSearchUpdateStep).toStepUri([filterId]),
    );
  }
}

class _MultiSelectSearchUpdateStep extends FlowStep {
  _MultiSelectSearchUpdateStep(this._aiAssistant, this._filtersRepository);

  final AiAssistant? _aiAssistant;
  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterId = args?.firstOrNull;
    final userInput = messageContext.text?.split(',');

    //todo if user input clear, then remove tags

    if (userInput == null || filterId == null) {
      return ReactionResponse(
        text: 'Oops, something went wrong. Please try again.',
      );
    }

    try {
      // final result = await _aiAssistant.parseTags(messageContext.userId.toString(), userInput);
      final tags = userInput;
      final unrecognizedInput =[];

      await _filtersRepository.setUserFilterValue(messageContext.userId, filterId, tags);

      final removeTags = tags == null || tags.isEmpty;

      return ReactionComposed(responses: [
        if (!removeTags)
          ReactionResponse(text: 'Your tags are set to: $tags\n\n We could not recognize: $unrecognizedInput'),
        if (removeTags) ReactionResponse(text: 'Tags removed'),
        ReactionRedirect(
          stepUri: (FiltersFlowInitialStep).toStepUri([filterId]),
        ),
      ]);
    } catch (e, stacktrace) {
      logger.e('Failed submitting filters', error: e, stackTrace: stacktrace);
      return ReactionResponse(
        text: 'Oops, something went wrong. Please try again.',
      );
    }
  }
}
