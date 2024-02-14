import 'package:database/src/utils/document_extensions.dart';
import 'package:firedart/firedart.dart';

const _collectionName = "filters";
const _feedStoppedKey = 'feed_stopped';

class UserDao {
  UserDao(this._firestore);

  final Firestore _firestore;

  CollectionReference get collection => _firestore.collection(_collectionName);

  Future<List<dynamic>?> getFilterOptions(int userId, String filterKey) {
    return _userDoc(userId).getFieldSafe(filterKey);
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

  /// - location
  /// - salary
  /// - seniority
  /// - commitment
  /// - head count
  /// - tags
  Future<List<String>> getUsersFor({
    String? location,
    int? salary,
    String? seniority,
    String? commitment,
    int? headCount,
    List<String>? tags,
  }) async {
    final query = collection
        .where('location', arrayContains: location)
        // .where('salary', isGreaterThanOrEqualTo: salaryRange?.first, isLessThanOrEqualTo: salaryRange?.last) //todo
        .where('seniority', arrayContains: seniority)
        .where('commitment', arrayContains: commitment)
        // .where('headcountEstimate', arrayContainsAny: headCount) //todo
        .where('tags', arrayContainsAny: tags);
    final docs = await query.get();
    return docs.map((e) => e.id).toList();
  }
}

extension UserDaoExt on UserDao {
  DocumentReference _userDoc(int userId) => collection.document(userId.toString());
}
