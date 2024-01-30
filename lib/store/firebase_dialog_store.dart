import 'package:chatterbox/chatterbox.dart';
import 'package:database/database.dart';

class FirebaseDialogStore implements PendingMessagesStore {
  FirebaseDialogStore(this.dao) : super();

  final DialogDao dao;

  @override
  Future<void> clearPending(int userId) => dao.clearPending(userId);

  @override
  Future<String?> retrievePending(int userId) => dao.retrievePending(userId);

  @override
  Future<void> setPending(int userId, String stepUrl) => dao.setPending(userId, stepUrl);
}
