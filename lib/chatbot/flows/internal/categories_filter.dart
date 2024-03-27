part of '../filters_setup_flow.dart';

const _pageSize = 11;

class _CategoriesSelectStep extends FlowStep {
  _CategoriesSelectStep(this._repo);

  final FiltersRepository _repo;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final userId = messageContext.userId;
    final selectedOptions = await _repo.getUserFilterOptions(userId, CategoryFilter.name) as List<String>? ?? [];
    final editMessageId = messageContext.editMessageId;

    final currentPage = args != null && args.isNotEmpty ? int.tryParse(args.first) ?? 0 : 0;
    final categories = CategoryFilter.options;
    final totalPages = (categories.length / _pageSize).ceil();

    final start = currentPage * _pageSize;
    final end = start + _pageSize;
    final pageCategories = categories.sublist(start, min(categories.length, end));

    return ReactionResponse(
      text: 'Select categories you are interested in',
      editMessageId: editMessageId,
      buttons: [
        ...pageCategories.map((option) {
          final isSelected = selectedOptions.contains(option.toString());
          return InlineButton(
            title: '${option.toString()} ${isSelected ? '✅' : ''}',
            nextStepUri: (_CategoriesUpdateStep).toStepUri([CategoryFilter.name, currentPage.toString(), option]),
          );
        }).toList(),
        if (currentPage > 0)
          InlineButton(
            title: '⬅️ Prev Page',
            nextStepUri: (_CategoriesSelectStep).toStepUri([(currentPage - 1).toString()]),
          ),
        if (currentPage < totalPages - 1)
          InlineButton(
            title: 'Next Page ➡️',
            nextStepUri: (_CategoriesSelectStep).toStepUri([(currentPage + 1).toString()]),
          ),
        InlineButton(
          title: '🔙 Back',
          nextStepUri: (FiltersFlowInitialStep).toStepUri([editMessageId.toString()]),
        ),
      ],
    );
  }
}

class _CategoriesUpdateStep extends FlowStep {
  _CategoriesUpdateStep(this._filtersRepository);

  final FiltersRepository _filtersRepository;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final filterId = args?.firstOrNull;
    final page = args?.secondOrNull;
    final option = args?.lastOrNull;

    if (filterId == null || option == null) {
      return ReactionNone();
    }

    await _filtersRepository.toggleUserFilterOption(messageContext.userId, filterId, option);

    return ReactionRedirect(stepUri: (_CategoriesSelectStep).toStepUri(page == null ? [] : [page]));
  }
}
