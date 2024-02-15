import 'package:jobstash_api/jobstash_api.dart';

class MessageFormatter {
  MessageFormatter._();

  static String createMessage(Post post) {
    final job = post.job;
    final summary = job.summary;
    final tags = job.tags;
    final organization = post.organization;
    final List<String> messageParts = [];

    messageParts.add(
        '<b><a href="https://jobstash.xyz/organizations/${organization.properties.id}/details">${organization.properties.name}</a></b> is hiring');


    if (summary == null) {
      throw ArgumentError('Summary is required');
    }
    messageParts.add(summary);

    if (job.minimumSalary != null && job.maximumSalary != null) {
      messageParts.add('Salary: ${job.minimumSalary} - ${job.maximumSalary}');
    }

    if (tags != null) {
      messageParts.add('🤓 ${tags.map((tag) => tag.name).join(', ')}');
    }

    messageParts.add(
        'Like what you see? Want more? <a href="https://t.me/jobstash">Telegram</a> | <a href="https://t.me/jobstashxyz">Telegram Community</a> | <a href="https://x.com/jobstash_xyz">Twitter</a> | <a href="https://warpcast.com/~/channel/jobstash">Farcaster</a>');

    String message = messageParts.join('\n\n');

    return message;
  }
}
