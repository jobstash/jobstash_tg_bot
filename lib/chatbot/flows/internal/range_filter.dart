part of '../filters_setup_flow.dart';

class _RangeFilterDisplayStep extends FlowStep {
  _RangeFilterDisplayStep(this._filtersRepository);

  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterId = args?.first;
    return _filtersRepository.withFilters(filterId, (filterId, filter, filters) async {
      final range = await _filtersRepository.getUserFilterValue(messageContext.userId, filterId);

      return ReactionResponse(
        editMessageId: messageContext.editMessageId,
        text: """Please input ${filter.label} range or type *Back* to go back.
Input format: <start> <end>
${range == null ? '' : '\nCurrent value: ${range.firstOrNull} - ${range.lastOrNull}'}
""",
        markdown: true,
        afterReplyUri: (_RangeFilterUpdateStep).toStepUri([filterId]),
      );
    });
  }
}

class _RangeFilterUpdateStep extends FlowStep {
  _RangeFilterUpdateStep(this._filtersRepository);

  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterId = args?.firstOrNull;
    final rangeParts = messageContext.text?.split(' ');
    final rangeInt = rangeParts?.map((e) => int.tryParse(e)).toList();

    if (filterId == null || rangeInt == null || rangeInt.length != 2 || rangeInt.contains(null)) {
      return ReactionResponse(
        text: 'Invalid range. Range format: <start> <end>',
      );
    }

    await _filtersRepository.setUserFilterValue(messageContext.userId, filterId, rangeInt);

    return ReactionComposed(responses: [
      ReactionResponse(text: 'Range updated: ${rangeInt.firstOrNull} - ${rangeInt.lastOrNull}'),
      ReactionRedirect(
        stepUri: (FiltersFlowInitialStep).toStepUri([filterId]),
      ),
    ]);
  }
}
