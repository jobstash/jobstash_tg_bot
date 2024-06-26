import 'package:database/src/dao/user_finder.dart';
import 'package:database/src/model/user_filters_dto.dart';
import 'package:database/src/utils/document_extensions.dart';
import 'package:firedart/firedart.dart';

class UserFiltersDao {
  UserFiltersDao(this._firestore);

  static const _collectionName = "filters";
  static const categoriesFilterKey = 'categories';
  static const tagsFilterKey = 'tags';
  static const communityFilterKey = 'community';

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

  Future<void> removeFilters(int userId, bool value) {
    return _userDoc(userId).delete();
  }

  Future<bool> isUserExists(int userId) {
    return _userDoc(userId).exists;
  }

  Future<List<String>> getUsersFor({
    List<String>? communities,
    List<String>? tags,
    String? category,
  }) async {
    final page = await collection.get();

    return UserFinder.getMatchingUsers(
      page: page,
      communities: communities,
      tags: tags,
      category: category,
    );
  }

  Future<int> getUsersCount() async {
    final documents = await collection.get();
    return documents.length;
  }
}

extension UserDaoExt on UserFiltersDao {
  DocumentReference _userDoc(int userId) => collection.document(userId.toString());
}
