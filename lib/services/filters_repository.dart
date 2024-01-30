import 'package:jobstash_api/jobstash_api.dart';

/// Applicable filters
/// - location
/// - salary
/// - seniority
/// - commitment
/// - head count
/// - tags
final _relevantFiltersIds = [
  'locations',
  'salary',
  'seniority',
  'commitments',
  'headcountEstimate',
  'tags',
];

class FiltersRepository {
  FiltersRepository(this._api) : _cache = _InMemoryCache();

  final JobStashApi _api;

  final _InMemoryCache _cache;

  Future<Map<String, Filter>> getRelevantFilters() async {
    final filters = _cache.filters;
    if (filters != null) {
      return filters;
    }

    final filtersFromApi = await _api.getAllFilters();
    final relevantFiltersMap = Map<String, Filter>.fromEntries(
      filtersFromApi.entries.where((e) => _relevantFiltersIds.contains(e.key)),
    );
    _cache.setFilters(relevantFiltersMap);
    return relevantFiltersMap;
  }
}

class _InMemoryCache {
  Map<String, Filter>? _filters;

  Map<String, Filter>? get filters => _filters;

  void setFilters(Map<String, Filter> filters) {
    _filters = filters;
  }
}
