import 'package:database/database.dart';
import 'package:database/src/model/user_filters_dto.dart';

class FiltersRepository {
  FiltersRepository(this._userDao);

  final UserFiltersDao _userDao;

  Future<UserFiltersDto?> getFilters(int userId) async {
    return _userDao.getFilters(userId);
  }

  Future<List<dynamic>?> getUserFilterOptions(int userId, String filterKey) async {
    final options = await _userDao.getFilterOptions(userId, filterKey);
    return options?.map((e) {
      return e.toString();
    }).toList();
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
