import 'package:collection/collection.dart';
import 'package:database/src/model/user_filters_dto.dart';
import 'package:database/src/utils/document_extensions.dart';
import 'package:firedart/firedart.dart';

const _collectionName = "filters";
const _feedStoppedKey = 'feed_stopped';

class UserFiltersDao {
  UserFiltersDao(this._firestore);

  final Firestore _firestore;

  CollectionReference get collection => _firestore.collection(_collectionName);

  Future<List<dynamic>?> getFilterOptions(int userId, String filterKey) {
    return _userDoc(userId).getFieldSafe(filterKey);
  }

  Future<UserFiltersDto?> getFilters(int userId) async {
    final doc = await _userDoc(userId).getSafe();
    return doc?.map;
  }

  Future<void> toggleFilterOption(int userId, String filterId, dynamic option) async {
    final existingOptions = await _userDoc(userId).getFieldSafe<List<dynamic>>(filterId);
    final contains = existingOptions?.contains(option) ?? false;
    if (contains) {
      await _userDoc(userId).removeItemFromSet(filterId, option);
    } else {
      await _userDoc(userId).addItemToSet(filterId, option);
    }
  }

  Future<dynamic> getFilterValue(int userId, String filterKey) {
    return _userDoc(userId).getFieldSafe(filterKey);
  }

  Future<void> setFilterValue(int userId, String filterKey, dynamic value) {
    return _userDoc(userId).update({
      filterKey: value,
    });
  }

  Future<void> setFeedStopped(int userId, bool value) {
    return _userDoc(userId).update({_feedStoppedKey: value});
  }

  Future<bool> isUserExists(int userId) {
    return _userDoc(userId).exists;
  }

  Future<bool> isFeedStopped(int userId) async {
    final value = await _userDoc(userId).getFieldSafe<bool>(_feedStoppedKey);
    return value == true;
  }

  Future<List<String>> getUsersFor({
    String? location,
    int? salary,
    String? seniority,
    String? commitment,
    int? headCount,
    List<String>? tags,
  }) async {
    final page = await collection.get();

    return _filter(page, location, salary, seniority, commitment, headCount, tags);
  }

  List<String> _filter(
    Page<Document> page,
    String? location,
    int? salary,
    String? seniority,
    String? commitment,
    int? headCount,
    List<String>? tags,
  ) {
    final users = page
      ..whereNotNull().where((element) {
        var headEstimate = (element['headcountEstimate'] as List<dynamic>?)?.map((e) => e as int?).toList();
        final headMin = headEstimate != null ? headEstimate[0] : null;
        final headMax = headEstimate != null ? headEstimate[1] : null;
        final salaryRange = (element['salary'] as List<dynamic>?)?.map((e) => e as int).toList();
        final salaryMin = salaryRange != null ? salaryRange[0] : null;
        final salaryMax = salaryRange != null ? salaryRange[1] : null;
        //
        final userLocations = element['locations'] as List<String>;
        final userSeniority = element['seniority'] as List<String>;
        final userCommitments = element['commitments'] as List<String>;
        final userTags = element['tags'] as List<String>;

        return (location == null || userLocations.isEmpty || userLocations.contains(location)) &&
            (seniority == null || userSeniority.isEmpty || userSeniority.contains(seniority)) &&
            (commitment == null || userCommitments.isEmpty || userCommitments.contains(commitment)) &&
            (headCount == null ||
                (headMin != null && headMax != null && headMin <= headCount && headCount <= headMax)) &&
            (tags == null || userTags.isEmpty || userTags.any((element) => tags.contains(element))) &&
            (salary == null || (salaryMin != null && salaryMax != null && salaryMin <= salary && salary <= salaryMax));
      });

    final usersList = users.toList();
    print('users: $usersList');
    return usersList.map((e) {
      var id = e.id;
      return id;
    }).toList();
  }

// List<String> _filter(Page<Document> page, String? location, String? seniority, String? commitment, int? headCount, List<String>? tags, int? salary) {
//   final users = page.where((element) {
//     final headEstimate = element['headcountEstimate'];
//     final headMin = (headEstimate as List<int>)[0];
//     final headMax = (headEstimate as List<int>)[1];
//     final salaryMin = (element['salary'] as List<int>)[0];
//     final salaryMax = (element['salary'] as List<int>)[1];
//
//     return (location == null || (element['locations'] as List<String>).contains(location)) &&
//         (seniority == null || (element['seniority'] as List<String>).contains(seniority)) &&
//         (commitment == null || (element['commitments'] as List<String>).contains(commitment)) &&
//         (headCount == null || (headMin <= headCount && headCount <= headMax)) &&
//         (tags == null || (element['tags'] as List<String>).any((element) => tags.contains(element))) &&
//         (salary == null || (salaryMin <= salary && salary <= salaryMax));
//   });
//
//   return users.map((e) => e.id).toList();
// }
}

extension UserDaoExt on UserFiltersDao {
  DocumentReference _userDoc(int userId) => collection.document(userId.toString());
}
