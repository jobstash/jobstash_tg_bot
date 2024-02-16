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

      await Database.initialize();

      final userDao = Database.createUserDao();

      //parse job
      final body = await parseRequestBody<List<dynamic>>(request);
      final posts = body.map((e) => Post.fromJson(e)).toList().sublist(0, 3);

      print('incoming message $body');
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
        await _sendMail(telegramApi, users, post);
      }));

      return Response.ok(
        null,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (error, st) {
      logger.e('Failed to process mailer request', error: error, stackTrace: st);
      await logErrorToTelegramChannel(error, st);
      return Response.internalServerError(body: {'error': error.toString()});
    }
  }

  Future<void> _sendMail(TelegramBotApi telegramApi, List<String> userIds, Post post) async {
    for (final userId in userIds) {
      try {
        telegramApi.sendHtmlMessage(int.parse(userId), MessageFormatter.createMessage(post));
      } catch (error, st) {
        logger.e('Failed to send mail to user $userId', error: error, stackTrace: st);
      }
    }
  }
}

extension TagToLink on Tag {
  String toLink() {
    return '[$this](https://jobstash.xyz/jobs?tags=${name.replaceAll(' ', '%20')})';
  }
}
