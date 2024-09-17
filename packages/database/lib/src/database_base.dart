import 'package:database/database.dart';
import 'package:firedart/firedart.dart';

class Database {
  const Database._();

  static Future<void> initialize(String firestoreProjectId) async {
    if (!Firestore.initialized) {
      Firestore.initialize(firestoreProjectId, useApplicationDefaultAuth: true);
    }
  }

  static UserFiltersDao createFiltersDao() => UserFiltersDao(Firestore.instance);

  static DialogDao createDialogDao() => DialogDao(Firestore.instance);
}
