import 'package:database/src/model/user.dart';
import 'package:database/src/utils/document_extensions.dart';
import 'package:firedart/firedart.dart';

const _collectionName = "users";
const _fieldIsOnboarded = "is_onboarded";
const _fieldUserLocale = "user_locale";
const _fieldLanguagePairs = "languagePairs";
const _fieldTargetLang = "target_lang";
const _fieldLevel = "level";

class UserDao {
  UserDao(this._firestore);

  final Firestore _firestore;

  CollectionReference get collection => _firestore.collection(_collectionName);

  Future<String?> getLocaleById(int userId) async {
    return _userDoc(userId).getFieldSafe(_fieldUserLocale);
  }

  Future<void> storeUserLocale(int userId, locale) => _userDoc(userId).update({
        _fieldUserLocale: locale,
      });

  Future<bool> isOnboarded(int userId) async {
    final value = await _userDoc(userId).getFieldSafe<bool>(_fieldIsOnboarded);
    return value ?? false;
  }

  Future<void> storeStudyLang(int userId, String lang, level) => _userDoc(userId).collection(_fieldLanguagePairs).add({
        _fieldTargetLang: lang,
        _fieldLevel: level,
      });

  Future<void> setOnboarded(int userId, [bool isOnboarded = true]) => _userDoc(userId).update({
        _fieldIsOnboarded: isOnboarded,
      });

  Future<void> deleteUser(int userId) => _userDoc(userId).delete();

  Future<User> getStudentData() {
    throw UnimplementedError();
  }
}

extension UserDaoExt on UserDao {
  DocumentReference _userDoc(int userId) => collection.document(userId.toString());
}
