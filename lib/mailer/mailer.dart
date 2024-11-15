import 'package:database/database.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/common/config.dart';
import 'package:jobstash_bot/common/utils/logger.dart';
import 'package:jobstash_bot/common/utils/parsing_utils.dart';
import 'package:jobstash_bot/mailer/internal/message_formatter.dart';
import 'package:jobstash_bot/mailer/internal/reporter.dart';
import 'package:shelf/shelf.dart';
import 'package:telegram_api/shared_api.dart';
import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

class Mailer {
  Future<Response> process(Request request) async {
    try {
      final telegramApi = TelegramBotApi(Config.botToken);

      await Database.initialize(Config.googleProjectId);

      final filtersDao = Database.createFiltersDao();

      //parse job
      final body = await parseRequestBody<List<dynamic>>(request);
      final posts = body.map((e) => Post.fromJson(e)).toList();

      final reporter = Reporter();

      for (final post in posts) {
        final userIds = await filtersDao.getUsersFor(
          communities: post.communities?.map((entry) => entry.normalizedName).toList(),
          category: post.category,
          tags: post.job.tags?.map((e) => e.name).toList(),
        );
        await _sendMail(telegramApi, userIds, post);
        reporter.aggregate(post, userIds);
      }

      await reporter.report(posts.length);

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
        final url = 'https://jobstash.xyz/jobs/${post.job.shortUUID}/details';
        telegramApi.sendMessage(
          int.parse(userId),
          MessageFormatter.createMessage(post),
          parseMode: ParseMode.html,
          disableLinkPreview: true,
          buttons: [InlineKeyboardButton(text: 'See Job Details', url: url)],
        );
      } catch (error, st) {
        logger.e('Failed to send mail to user $userId', error: error, stackTrace: st);
        logErrorToTelegramChannel('Failed to send mail to user $userId', error, st);
      }
    }
  }
}
