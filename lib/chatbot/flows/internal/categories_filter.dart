part of '../filters_setup_flow.dart';

class _CategoriesSelectStep extends FlowStep {
  _CategoriesSelectStep(this._repo);

  final FiltersRepository _repo;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final userId = messageContext.userId;
    final selectedOptions = await _repo.getUserFilterOptions(userId, CategoryFilter.name) as List<String>? ?? [];
    final editMessageId = messageContext.editMessageId;

    final categories = CategoryFilter.options;

    return ReactionResponse(
      text: 'Select categories:',
      editMessageId: editMessageId,
      buttons: categories
          .map((option) {
            final isSelected = selectedOptions.contains(option.toString()) == true;
            return InlineButton(
              title: '${option.toString()} ${isSelected ? '✅' : ''}',
              nextStepUri: (_CategoriesUpdateStep).toStepUri([CategoryFilter.name, option]),
            );
          })
          .toList()
          .withBackButton((FiltersFlowInitialStep).toStepUri(['', editMessageId.toString()])),
    );
  }
}

class _CategoriesUpdateStep extends FlowStep {
  _CategoriesUpdateStep(this._filtersRepository);

  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterId = args?.firstOrNull;
    final option = args?.lastOrNull;
    if (filterId == null || option == null) {
      return ReactionNone();
    }

    await _filtersRepository.toggleUserFilterOption(messageContext.userId, filterId, option);

    return ReactionRedirect(stepUri: (_CategoriesSelectStep).toStepUri([filterId]));
  }
}
