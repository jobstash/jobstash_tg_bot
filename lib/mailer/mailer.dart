import 'package:database/database.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/common/config.dart';
import 'package:jobstash_bot/common/utils/logger.dart';
import 'package:jobstash_bot/common/utils/parsing_utils.dart';
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
        final message = _createMessage(job);
        await telegramApi.sendMessage(int.parse(userId), message);
      } catch (error, st) {
        logger.e('Failed to send mail to user $userId', error: error, stackTrace: st);
      }
    }
  }

  // Hiro Systems PBC (https://jobstash.xyz/organizations/2486/details) is hiring a remote Sr. DevOps Engineer (https://jobstash.xyz/jobs/aEvHFQ/details)
  //
  // Hiro is looking for a DevOps Engineer to help scale infrastructure and build developer empowering solutions
  //
  // 💵 $175,000 - $195,000
  //
  // 🤓 application runtime (https://jobstash.xyz/jobs?tags=application%20runtime) | Security (https://jobstash.xyz/jobs?tags=security) | NodeJS (https://jobstash.xyz/jobs?tags=nodejs) | DevOps (https://jobstash.xyz/jobs?tags=devops) | Grafana (https://jobstash.xyz/jobs?tags=grafana) | Caching (https://jobstash.xyz/jobs?tags=caching) | Bash (https://jobstash.xyz/jobs?tags=bash) | Postgres (https://jobstash.xyz/jobs?tags=postgres) | TCP/IP (https://jobstash.xyz/jobs?tags=tcp/ip) | Database (https://jobstash.xyz/jobs?tags=database) | Go (https://jobstash.xyz/jobs?tags=go) | Linkerd (https://jobstash.xyz/jobs?tags=linkerd) | Azure (https://jobstash.xyz/jobs?tags=azure) | Istio (https://jobstash.xyz/jobs?tags=istio) | HTTP (https://jobstash.xyz/jobs?tags=http) | CI/CD (https://jobstash.xyz/jobs?tags=ci/cd) | Kubernetes security (https://jobstash.xyz/jobs?tags=kubernetes%20security) | Redis (https://jobstash.xyz/jobs?tags=redis) | AWS (https://jobstash.xyz/jobs?tags=aws) | service mesh (https://jobstash.xyz/jobs?tags=service%20mesh)
  //
  // Like what you see? Want more? Telegram (https://t.me/jobstash) | Telegram Community (https://t.me/jobstashxyz) | Twitter (https://x.com/jobstash_xyz) | Farcaster (https://warpcast.com/~/channel/jobstash)
  String _createMessage(Job job) {
    return '''
    ${job.organization?.name} is hiring a remote ${job.title} (${job.url})
    
    ${job.description}
    
    💵 ${job.salary}
    
    ${job.tags?.map((tag) => tag.toLink()).join(' | ')}
    
    Like what you see? Want more? [Telegram](https://t.me/jobstash) | [Telegram Community](https://t.me/jobstashxyz) | [Twitter](https://x.com/jobstash_xyz) | [Farcaster](https://warpcast.com/~/channel/jobstash)
    ''';
  }
}

extension TagToLink on Tag {
  String toLink() {
    return '[$this](https://jobstash.xyz/jobs?tags=${name.replaceAll(' ', '%20')})';
  }
}
