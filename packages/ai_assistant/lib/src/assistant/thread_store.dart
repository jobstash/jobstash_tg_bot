abstract class ThreadStore {
  Future<String?> getThreadId(String userId);

  Future<void> setThreadId(String userId, String threadId);
}
