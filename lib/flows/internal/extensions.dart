part of '../filters_setup_flow.dart';

extension on FiltersRepository {
  Future<Reaction> withFilters(
    String? filterId,
    Future<Reaction> Function(String filterId, Filter filter, Map<String, Filter>) action,
  ) async {
    if (filterId == null) {
      return ReactionResponse(text: 'Something went wrong.\n\nFilter $filterId not found');
    }

    final filters = await getRelevantFilters();

    final Filter? filter = filters[filterId];
    if (filter == null) {
      return ReactionResponse(text: 'Something went wrong.\n\nFilter for $filterId not found');
    }

    return action(filterId, filter, filters);
  }
}

extension on List<InlineButton> {
  List<InlineButton> withBackButton(String stepUri) {
    return [
      ...this,
      InlineButton(
        title: 'Back',
        nextStepUri: stepUri,
      ),
    ];
  }
}
