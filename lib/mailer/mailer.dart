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
      Config.init();

      final telegramApi = TelegramBotApi(Config.botToken);

      await Database.initialize();

      final userDao = Database.createUserDao();

      //parse job
      final body = await parseRequestBody(request);
      final response = JobsResponse.fromJson(body);

      print('incoming message $body');
      await Future.wait(response.data.map((job) async {
        final users = await _getInterestedUsers(userDao, job);
        await _sendMail(telegramApi, users, job);
      }));

      return Response.ok(
        null,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (error, st) {
      logger.e('Failed to process mailer request', error: error, stackTrace: st);
      return Response.internalServerError(body: {'error': error.toString()});
    }
  }

  Future<List<String>> _getInterestedUsers(UserFiltersDao userDao, Job job) async {
    final users = await userDao.getUsersFor(
      tags: job.tags?.map((e) => e.normalizedName).toList(),
      location: job.location,
      salary: job.salary,
      seniority: job.seniority,
      commitment: job.commitment,
      headCount: job.organization?.headcountEstimate,
    );
    return users;
  }

  Future<void> _sendMail(TelegramBotApi telegramApi, List<String> userIds, Job job) async {
    for (final userId in userIds) {
      try {
        telegramApi.sendHtmlMessage(int.parse(userId), MessageFormatter.createMessage(job));
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
