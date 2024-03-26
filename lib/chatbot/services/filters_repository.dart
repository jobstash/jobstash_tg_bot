import 'package:database/database.dart';
import 'package:database/src/model/user_filters_dto.dart';
import 'package:jobstash_api/jobstash_api.dart';

/// Applicable filters
/// - location
/// - salary
/// - seniority
/// - commitment
/// - head count
/// - tags
final _relevantFiltersIds = [
  // 'locations',
  // 'salary',
  // 'seniority',
  // 'commitments',
  // 'headcountEstimate',
  'tags',
];

class FiltersRepository {
  FiltersRepository(this._api, this._userDao) : _cache = _InMemoryCache();

  final JobStashApi _api;
  final UserFiltersDao _userDao;

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

  Future<UserFiltersDto?> getFilters(int userId) async {
    return _userDao.getFilters(userId);
  }

  Future<List<dynamic>?> getUserFilterOptions(int userId, String filterKey) async {
    return _userDao.getFilterOptions(userId, filterKey);
  }

  Future<void> setUserFilterValue(int userId, String filterKey, dynamic value) {
    return _userDao.setFilterValue(userId, filterKey, value);
  }

  Future<List<String>?> getUserFilterValue(int userId, String filterKey) async {
    final filterValue = await _userDao.getFilterValue(userId, filterKey);
    if (filterValue == null) {
      return null;
    }
    final rangeString = filterValue.toString().split(', ');
    final first = rangeString.firstOrNull?.toString();
    final last = rangeString.lastOrNull?.toString();
    return first == null || last == null ? null : [first, last];
  }

  Future<void> toggleUserFilterOption(int userId, String filterId, dynamic option) {
    return _userDao.toggleFilterOption(userId, filterId, option);
  }

  Future<void> removeFilters(int userId, bool value) {
    return _userDao.removeFilters(userId, value);
  }

  Future<bool> isUserExists(int userId) {
    return _userDao.isUserExists(userId);
  }

  Future<int> getUsersCount() {
    return _userDao.getUsersCount();
  }
}

class _InMemoryCache {
  Map<String, Filter>? _filters;

  Map<String, Filter>? get filters => _filters;

  void setFilters(Map<String, Filter> filters) {
    _filters = filters;
  }
}
