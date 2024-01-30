import 'package:chatterbox/chatterbox.dart';

class StoreProxy extends PendingMessagesStore {
  final map = <int, String>{};

  @override
  Future<void> clearPending(int userId) async {
    map.remove(userId);
  }

  @override
  Future<String?> retrievePending(int userId) async {
    return map[userId];
  }

  @override
  Future<void> setPending(int userId, String stepUrl) async {
    map[userId] = stepUrl;
  }
}
