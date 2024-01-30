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
        text: """Please input new ${filter.label} or type ~~Back~~ to go back.
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
    if (filterId == null || rangeParts == null || rangeParts.length != 2) {
      return ReactionResponse(
        text: 'Invalid range. Range format: <start> <end>',
      );
    }

    await _filtersRepository.setUserFilterValue(messageContext.userId, filterId, rangeParts);

    return ReactionRedirect(
      stepUri: (_FilterDetailedStep).toStepUri([filterId]),
    );

    // final rangeParts = range.split('-');
    // if (rangeParts.length != 2) {
    //   return ReactionResponse(text: 'Invalid range');
    // }
    //
    // final rangeStart = rangeParts.firstOrNull;
    // final rangeEnd = rangeParts.lastOrNull;
    //
    // if (rangeStart == null || rangeEnd == null) {
    //   return ReactionResponse(text: 'Invalid range');
    // }
    //
    // await _filtersRepository.setUserFilterValue(messageContext.userId, filterId, rangeStart, rangeEnd);
    //
    // return ReactionRedirect(stepUri: (_FilterDetailedStep).toStepUri([filterId]));
  }
}
