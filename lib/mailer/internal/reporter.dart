import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/common/config.dart';
import 'package:jobstash_bot/common/utils/logger.dart';

class Reporter {
  final userIdToPostCountMap = <String, int>{};

  void aggregate(Post post, List<String> userIds) {
    for (var userId in userIds) {
      final value = userIdToPostCountMap[userId];
      userIdToPostCountMap[userId] = (value ?? 0) + 1;
    }
  }

  Future<void> report(int postsCount) async {
    final userIds = userIdToPostCountMap.keys;

    final usersCountToPostCountMap = <int, int>{};
    for (var entry in userIdToPostCountMap.entries) {
      final value = usersCountToPostCountMap[entry.value];
      usersCountToPostCountMap[entry.value] = (value ?? 0) + 1;
    }

    final sortedUserPostCounts = usersCountToPostCountMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key));

    final reportParts = <String>[];
    reportParts.add('Job Posting Report');
    reportParts.add('Users count: ${userIds.length}');
    reportParts.add('Job postings: $postsCount');
    for (var entry in sortedUserPostCounts) {
      reportParts.add('${entry.value} users Received ${entry.key} job postings');
    }

    logger.d(reportParts.join('\n'));
    if (!Config.isDevEnv) {
      logToTelegramChannel(reportParts.join('\n'));
    }
  }
}
