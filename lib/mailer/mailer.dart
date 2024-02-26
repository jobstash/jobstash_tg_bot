import 'package:database/database.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/common/config.dart';
import 'package:jobstash_bot/common/utils/logger.dart';
import 'package:jobstash_bot/common/utils/parsing_utils.dart';
import 'package:jobstash_bot/mailer/internal/message_formatter.dart';
import 'package:shelf/shelf.dart';
import 'package:telegram_api/shared_api.dart';

class Mailer {
  Future<Response> process(Request request) async {
    try {
      final telegramApi = TelegramBotApi(Config.botToken);

      await Database.initialize(Config.isDevEnv);

      final userDao = Database.createUserDao();

      //parse job
      final body = await parseRequestBody<List<dynamic>>(request);
      final posts = body.map((e) => Post.fromJson(e)).toList();

      //store how many users are receiving how many job postings for logging and print to console
      final userPostCount = <int, int>{};

      await Future.wait(posts.map((post) async {
        final users = await userDao.getUsersFor(
          location: post.job.location,
          minimumSalary: post.job.minimumSalary,
          maximumSalary: post.job.maximumSalary,
          seniority: post.job.seniority,
          // commitment: post.job.commitment, //todo
          minimumHeadCount: post.organization.properties.headcountEstimate?.low,
          maximumHeadCount: post.organization.properties.headcountEstimate?.high,
          tags: post.job.tags?.map((e) => e.name).toList(),
        );
        userPostCount[post.hashCode] = users.length;
        await _sendMail(telegramApi, users, post);
      }));

      final reportParts = <String>[];
      reportParts.add('Processed ${posts.length} posts');

      if (userPostCount.values.fold(0, (prev, element) => prev + element) == 0) {
        reportParts.add('No users to send mail to');
      } else {
        userPostCount.forEach((key, value) {
          reportParts.add('Sent mail to $value users for post $key');
        });
      }

      logger.d(reportParts.join('\n'));
      logToTelegramChannel(reportParts.join('\n'));

      return Response.ok(
        null,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (error, st) {
      logger.e('Failed to process mailer request', error: error, stackTrace: st);
      await logErrorToTelegramChannel('Failed to process mailer request', error, st);
      return Response.internalServerError(body: {'error': error.toString()});
    }
  }

  Future<void> _sendMail(TelegramBotApi telegramApi, List<String> userIds, Post post) async {
    for (final userId in userIds) {
      try {
        telegramApi.sendHtmlMessage(int.parse(userId), MessageFormatter.createMessage(post));
      } catch (error, st) {
        logger.e('Failed to send mail to user $userId', error: error, stackTrace: st);
        logErrorToTelegramChannel('Failed to send mail to user $userId', error, st);
      }
    }
  }
}

extension TagToLink on Tag {
  String toLink() {
    return '[$this](https://jobstash.xyz/jobs?tags=${name.replaceAll(' ', '%20')})';
  }
}
