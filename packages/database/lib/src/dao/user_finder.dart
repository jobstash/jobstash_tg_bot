import 'package:collection/collection.dart';
import 'package:database/database.dart';
import 'package:firedart/firedart.dart';

class UserFinder {
  UserFinder._();

  static const _greenWhenJobMissingParam = false;
  static const _greenWhenUserHaveNoFilter = false;

  static List<String> getInterestedUsers(
    Page<Document> page,
    String? location,
    int? minimumSalary,
    int? maximumSalary,
    String? seniority,
    String? commitment,
    int? minimumHeadCount,
    int? maximumHeadCount,
    List<String>? tags,
    String? category,
  ) {
    final users = page.whereNotNull().where((userFilters) {
      final tagsMatch = _checkArrayIntersection(userFilters, 'tags', tags);
      final categoryMatch = _checkArrayContains(userFilters, categoriesFilterKey, category);
      return tagsMatch || categoryMatch;
      // _checkArrayContains(userFilters, 'locations', location) &&
      //   _checkArrayContains(userFilters, 'seniority', seniority) &&
      // (commitment == null || userCommitments.isEmpty || userCommitments.contains(commitment)) &&
      // _checkRange(userFilters, 'headcountEstimate', minimumHeadCount, maximumHeadCount) &&
      // _checkRange(userFilters, 'salary', minimumSalary, maximumSalary);
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
}
