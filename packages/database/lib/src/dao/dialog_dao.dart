import 'package:database/src/utils/document_extensions.dart';
import 'package:firedart/firedart.dart';

const _collectionDialogs = "dialogs";

class DialogDao {
  DialogDao(this._firestore);

  final Firestore _firestore;

  CollectionReference get collection => _firestore.collection(_collectionDialogs);

  Future<String?> retrievePending(int userId) async {
    final stepId = await collection.document('$userId').getFieldSafe('pending_step_url');
    if (stepId != null) {
      collection.document('$userId').delete();
    }
    return stepId;
  }

  Future<void> setPending(int userId, String stepUrl) async => collection.document('$userId').update({
        'pending_step_url': stepUrl,
      });

  Future<void> clearPending(int userId) => collection.document('$userId').delete();
}
