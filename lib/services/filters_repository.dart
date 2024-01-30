import 'package:database/database.dart';
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
  FiltersRepository(this._api, this._userDao) : _cache = _InMemoryCache();

  final JobStashApi _api;
  final UserDao _userDao;

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

  Future<List<dynamic>?> getUserFilterOptions(int userId, String filterKey) async {
    return _userDao.getFilterOptions(userId, filterKey);
  }

  Future<void> toggleUserFilterOption(int userId, String filterId, dynamic option) {
    return _userDao.toggleFilterOption(userId, filterId, option);
  }


}

class _InMemoryCache {
  Map<String, Filter>? _filters;

  Map<String, Filter>? get filters => _filters;

  void setFilters(Map<String, Filter> filters) {
    _filters = filters;
  }
}
