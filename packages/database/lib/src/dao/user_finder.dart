import 'package:collection/collection.dart';
import 'package:database/database.dart';
import 'package:firedart/firedart.dart';

class UserFinder {
  UserFinder._();

  static const _greenWhenJobMissingParam = false;
  static const _greenWhenUserHaveNoFilter = false;

  static List<String> getMatchingUsers({
    required Page<Document> page,
    String? classification,
    List<String>? tags,
    String? category,
  }) {
    final users = page.whereNotNull().where((userFilters) {
      final classificationMatch = _checkMatch(userFilters, UserFiltersDao.classificationFilterKey, classification);
      final tagsMatch = _checkArrayIntersection(userFilters, UserFiltersDao.tagsFilterKey, tags);
      final categoryMatch = _checkArrayContains(userFilters, UserFiltersDao.categoriesFilterKey, category);
      return classificationMatch || tagsMatch || categoryMatch;
    });

    final usersList = users.toList();
    return usersList.map((e) => e.id).toList();
  }

  static bool _checkArrayContains(Document doc, String fieldId, String? jobEntry) {
    final userFilter = doc[fieldId];
    try {
      print('userFilter: $userFilter, id: $fieldId, jobEntry: $jobEntry');
      final userFilterOptions = userFilter?.map((e) => e.toString()).toList() as List<dynamic>?;

      if (userFilterOptions == null || userFilterOptions.isEmpty) {
        // User does not have this filter set, so it should be true
        return _greenWhenUserHaveNoFilter;
      }

      if (jobEntry == null && !_greenWhenJobMissingParam) {
        // Job does not have this property set
        return false;
      }

      return userFilterOptions.contains(jobEntry);
    } catch (e, st) {
      print(e);
      print(st);
      return true;
    }
  }

  static bool _checkArrayIntersection(Document doc, String fieldId, List<String>? jobEntries) {
    final array = doc[fieldId]?.map((e) => e.toString()).toList() as List<dynamic>?;

    if (array == null || array.isEmpty) {
      // User does not have this filter set, so it should be true
      return _greenWhenUserHaveNoFilter;
    }

    if (jobEntries == null) {
      // Job does not have this property set
      return _greenWhenJobMissingParam;
    }

    return array.any((element) => jobEntries.contains(element));
  }

  static bool _checkRange(Document doc, String fieldId, int? minimumSalary, int? maximumSalary) {
    final salaryRange = (doc[fieldId] as List<dynamic>?)?.map((e) => e as int).toList();
    final userMinSalary = salaryRange != null ? salaryRange[0] : null;
    final userMaxSalary = salaryRange != null ? salaryRange[1] : null;

    //if user filter is not set, then it should be true
    if (userMaxSalary == null && userMinSalary == null) {
      return true;
    }

    // if job does not have range and user does
    if (minimumSalary == null && maximumSalary == null) {
      return _greenWhenJobMissingParam;
    }

    // check if user range is within job range
    return (minimumSalary == null || userMinSalary! >= minimumSalary) &&
        (maximumSalary == null || userMaxSalary! <= maximumSalary);
  }

  static bool _checkMatch(Document userFilters, String fieldId, String? postValue) {
    final userClassification = userFilters[fieldId];
    return postValue != null && userClassification == postValue;
  }
}
