import 'package:database/database.dart';
import 'package:firedart/firedart.dart';

class Database {
  const Database._();

  static Future<void> initialize(bool isDebug) async {
    if (!Firestore.initialized) {
      Firestore.initialize(isDebug ? 'jobstash-bot' : 'beaming-figure-430316-k1', useApplicationDefaultAuth: true);
    }
  }

  static UserFiltersDao createFiltersDao() => UserFiltersDao(Firestore.instance);

  static DialogDao createDialogDao() => DialogDao(Firestore.instance);
}
