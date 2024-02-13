part of '../filters_setup_flow.dart';

class _MultiSelectSearchDisplayStep extends FlowStep {
  _MultiSelectSearchDisplayStep(this._aiAssistant, this._filtersRepository);

  final AiAssistant _aiAssistant;
  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterId = args?.first;
    return _filtersRepository.withFilters(filterId, (filterId, filter, filters) async {
      final range = await _filtersRepository.getUserFilterValue(messageContext.userId, filterId);

      return ReactionResponse(
        editMessageId: messageContext.editMessageId,
        text: """Please type tags/ technologies you are interested in separated by comma or type *Back* to go back.
_Example: Kotlin, Java, Python_ 
""",
        markdown: true,
        afterReplyUri: (_MultiSelectSearchUpdateStep).toStepUri([filterId]),
      );
    });
  }
}

class _MultiSelectSearchUpdateStep extends FlowStep {
  _MultiSelectSearchUpdateStep(this._filtersRepository);

  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterId = args?.firstOrNull;
    final tags = messageContext.text?.split(',');

    if (filterId == null) {
      return ReactionResponse(
        text: 'Invalid range. Range format: <start> <end>',
      );
    }

    await _filtersRepository.setUserFilterValue(messageContext.userId, filterId, tags);

    final removeTags = tags == null || tags.isEmpty;

    return ReactionComposed(responses: [
      if (!removeTags) ReactionResponse(text: 'Your tags are: $tags'),
      if (removeTags) ReactionResponse(text: 'Tags removed'),
      ReactionRedirect(
        stepUri: (_FilterDetailedStep).toStepUri([filterId]),
      ),
    ]);
  }
}
