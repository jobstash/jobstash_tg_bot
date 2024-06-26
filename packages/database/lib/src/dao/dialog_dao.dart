import 'package:database/src/utils/document_extensions.dart';
import 'package:firedart/firedart.dart';

const _collectionDialogs = "dialogs";

class DialogDao {
  DialogDao(this._firestore);

  final Firestore _firestore;

  CollectionReference get collection => _firestore.collection(_collectionDialogs);

  Future<String?> retrievePending(int userId, int chatId) async {
    final stepId = await collection.document('$chatId-$userId').getFieldSafe('pending_step_url');
    if (stepId != null) {
      await clearPendingDialogUri(userId, chatId);
    }
    return stepId;
  }

  Future<void> setPending(int userId, int chatId, String stepUrl) async =>
      collection.document('$chatId-$userId').update({
        'pending_step_url': stepUrl,
      });

  Future<void> clearPendingDialogUri(int userId, int chatId) {
    return collection.document('$chatId-$userId').delete();
  }

  Future<String?> getAssistantThreadId(String userId) =>
      collection.document(userId).getFieldSafe('assistant_thread_id');

  Future<void> clearAssistantThreadId(String userId) => collection.document(userId).update({
        'assistant_thread_id': null,
      });

  Future<void> setAssistantThreadId(String userId, String threadId) => collection.document(userId).update({
        'assistant_thread_id': threadId,
      });

  Future<void> removeAssistantThreadId(String userId) => collection.document(userId).delete();
}
