part of '../filters_setup_flow.dart';

class _MultiSelectFilterDisplayStep extends FlowStep {
  _MultiSelectFilterDisplayStep(this._filtersRepository);

  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterId = args?.first;
    final secondArg = args?.elementAtOrNull(1);
    final editMessageId = secondArg != null ? int.tryParse(secondArg) : messageContext.editMessageId;

    if (filterId == null) {
      return ReactionNone();
    }

    final filters = await _filtersRepository.getRelevantFilters();

    final Filter? filter = filters[filterId];
    if (filter == null) {
      return ReactionResponse(text: 'Something went wrong.\n\nFilter $filterId not found');
    }

    final selectedOptions = await _filtersRepository.getUserFilterOptions(messageContext.userId, filterId);

    return ReactionResponse(
      text: filter.label,
      editMessageId: editMessageId,
      buttons: filter.options
              ?.map((option) {
                final isSelected = selectedOptions?.contains(option.toString()) == true;
                return InlineButton(
                  title: '${option.toString()} ${isSelected ? '✅' : ''}',
                  nextStepUri: (_MultiSelectFilterUpdateStep).toStepUri([filterId, option]),
                );
              })
              .toList()
              .withBackButton((_FilterDetailedStep).toStepUri([filterId])) ??
          [],
    );
  }
}

class _MultiSelectFilterUpdateStep extends FlowStep {
  _MultiSelectFilterUpdateStep(this._filtersRepository);

  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterId = args?.firstOrNull;
    final option = args?.lastOrNull;
    if (filterId == null || option == null) {
      return ReactionNone();
    }

    await _filtersRepository.toggleUserFilterOption(messageContext.userId, filterId, option);

    return ReactionRedirect(stepUri: (_MultiSelectFilterDisplayStep).toStepUri([filterId]));
  }
}
