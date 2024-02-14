import 'package:jobstash_api/jobstash_api.dart';

class MessageFormatter {

  static String createMessage(Job job) {
    final organization = job.organization;
    List<String> messageParts = [];

    messageParts.add(
        '<b><a href="https://jobstash.xyz/organizations/${organization!.id}/details">${organization.name}</a></b> is hiring');

    messageParts.add(job.summary!);

    if (job.minimumSalary != null && job.maximumSalary != null) {
      messageParts.add('Salary: ${job.minimumSalary} - ${job.maximumSalary}');
    }

    messageParts.add('🤓 ${job.tags!.map((tag) => tag.name).join(', ')}');

    messageParts.add(
        'Like what you see? Want more? <a href="https://t.me/jobstash">Telegram</a> | <a href="https://t.me/jobstashxyz">Telegram Community</a> | <a href="https://x.com/jobstash_xyz">Twitter</a> | <a href="https://warpcast.com/~/channel/jobstash">Farcaster</a>');

    String message = messageParts.join('\n\n');

    return message;
  }
}
