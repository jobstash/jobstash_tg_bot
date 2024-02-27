import 'package:jobstash_api/jobstash_api.dart';

class MessageFormatter {
  MessageFormatter._();

  static String createMessage(Post post) {
    final job = post.job;
    final summary = job.summary;
    final tags = job.tags;
    final organization = post.organization;

    final List<String> messageParts = [];
    final locationName = job.locationType?.name;
    messageParts.add(
        '<b><a href="https://jobstash.xyz/organizations/${organization.properties.orgId}/details">'
            '${organization.properties.name}</a></b> is hiring ${job.locationType != null
            && locationName != null ? locationName == 'REMOTE' ? "a remote"
            : locationName == 'HYBRID' ? "a hybrid"
            : "an onsite" : "a"} <b><a href="https://jobstash.xyz/jobs/${job.shortUUID}/details">${job.title}</a></b> '
            '${job.locationType != null && locationName != null && (locationName == 'HYBRID'
            || locationName == 'ONSITE') ? "in ${job.location}" : ""}');

    if (summary == null) {
      throw ArgumentError('Summary is required');
    }
    messageParts.add(summary);

    if (job.minimumSalary != null && job.maximumSalary != null) {
      messageParts.add('Salary: ${job.minimumSalary} - ${job.maximumSalary}');
    }

    if (tags != null) {
      messageParts.add(
          '🤓 ${tags.map((tag) => '<a href="https://jobstash.xyz/jobs?tags=${Uri.encodeComponent(tag.normalizedName)}">${tag.name}</a>').join(', ')}');
    }

    messageParts.add(
        'Like what you see? Want more? <a href="https://t.me/jobstash">Telegram</a> | <a href="https://t.me/jobstashxyz">Telegram Community</a> | <a href="https://x.com/jobstash_xyz">Twitter</a> | <a href="https://warpcast.com/~/channel/jobstash">Farcaster</a>');

    final message = messageParts.join('\n\n');

    return message;
  }
}
