import 'package:chatterbox/chatterbox.dart';
import 'package:database/database.dart';

class FirebaseDialogStore implements PendingMessagesStore {
  FirebaseDialogStore(this.dao) : super();

  final DialogDao dao;

  @override
  Future<void> clearPending(int userId, int chatId) => dao.clearPendingDialogUri(userId, chatId);

  @override
  Future<String?> retrievePending(int userId, int chatId) => dao.retrievePending(userId, chatId);

  @override
  Future<void> setPending(int userId, int chatId, String stepUrl) => dao.setPending(userId, chatId, stepUrl);
}
