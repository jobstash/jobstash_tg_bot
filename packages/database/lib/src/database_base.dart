import 'package:database/database.dart';
import 'package:firedart/firedart.dart';

class Database {
  const Database._();

  static Future<void> initialize(bool isDebug) async {
    if (!Firestore.initialized) {
      Firestore.initialize(isDebug ? 'jobstash-bot' : 'jobstash', useApplicationDefaultAuth: true);
    }
  }

  static UserFiltersDao createUserDao() => UserFiltersDao(Firestore.instance);

  static DialogDao createDialogDao() => DialogDao(Firestore.instance);
}
