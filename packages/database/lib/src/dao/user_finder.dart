import 'package:collection/collection.dart';
import 'package:firedart/firedart.dart';

class UserFinder {
  UserFinder._();

  static const _checkWhenJobMissingParam = true;

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
  ) {
    final users = page.whereNotNull().where((userFilters) {
      return _checkArrayContains(userFilters, 'locations', location) &&
          _checkArrayContains(userFilters, 'seniority', seniority) &&
          // (commitment == null || userCommitments.isEmpty || userCommitments.contains(commitment)) &&
          _checkRange(userFilters, 'headcountEstimate', minimumHeadCount, maximumHeadCount) &&
          _checkArrayIntersection(userFilters, 'tags', tags) &&
          _checkRange(userFilters, 'salary', minimumSalary, maximumSalary);
    });

    final usersList = users.toList();
    return usersList.map((e) => e.id).toList();
  }

  static bool _checkArrayContains(Document userFilters, String fieldId, String? jobEntry) {
    final userFilter = userFilters[fieldId];
    try {
      print('userFilter: $userFilter, id: $fieldId, jobEntry: $jobEntry');
      final array = userFilter?.map((e) => e.toString()).toList() as List<dynamic>?;

      if (array == null) {
        // User does not have this filter set, so it should be true
        return true;
      }

      if (jobEntry == null) {
        // Job does not have this property set
        return _checkWhenJobMissingParam;
      }

      return array.isEmpty || array.contains(jobEntry);
    } catch (e, st) {
      print(e);
      print(st);
      return true;
    }
  }

  static bool _checkArrayIntersection(Document userFilters, String fieldId, List<String>? jobEntries) {
    final array = userFilters[fieldId]?.map((e) => e.toString()).toList() as List<dynamic>?;

    if (array == null) {
      // User does not have this filter set, so it should be true
      return true;
    }

    if (jobEntries == null) {
      // Job does not have this property set
      return _checkWhenJobMissingParam;
    }

    return array.isEmpty || array.any((element) => jobEntries.contains(element));
  }

  static bool _checkRange(Document userFilters, String fieldId, int? minimumSalary, int? maximumSalary) {
    final salaryRange = (userFilters[fieldId] as List<dynamic>?)?.map((e) => e as int).toList();
    final userMinSalary = salaryRange != null ? salaryRange[0] : null;
    final userMaxSalary = salaryRange != null ? salaryRange[1] : null;

    //if user filter is not set, then it should be true
    if (userMaxSalary == null && userMinSalary == null) {
      return true;
    }

    // if job does not have range and user does
    if (minimumSalary == null && maximumSalary == null) {
      return _checkWhenJobMissingParam;
    }

    // check if user range is within job range
    return (minimumSalary == null || userMinSalary! >= minimumSalary) &&
        (maximumSalary == null || userMaxSalary! <= maximumSalary);
  }
}
