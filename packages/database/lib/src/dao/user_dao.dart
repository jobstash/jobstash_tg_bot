import 'package:database/src/utils/document_extensions.dart';
import 'package:firedart/firedart.dart';

const _collectionName = "users";

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
    return _userDoc(userId).update({'feed_stopped': value});
  }

  Future<bool> isUserExists(int userId) {
    return _userDoc(userId).exists;
  }

  Future<bool> isFeedStopped(int userId) async {
    final value = await _userDoc(userId).getFieldSafe<bool>('feed_stopped');
    return value == true;
  }
}

extension UserDaoExt on UserDao {
  DocumentReference _userDoc(int userId) => collection.document(userId.toString());
}
