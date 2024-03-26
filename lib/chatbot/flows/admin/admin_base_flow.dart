import 'package:chatterbox/chatterbox.dart';
import 'package:jobstash_bot/common/config.dart';

abstract class AdminFlowStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    return verifyAdmin(messageContext, () async {
      return handleAdmin(messageContext, args);
    });
  }

  Future<Reaction> handleAdmin(MessageContext messageContext, [List<String>? args]);
}

Future<Reaction> verifyAdmin(MessageContext messageContext, Future<Reaction> Function() callback) async {
  if (Config.checkIsAdmin(messageContext.userId)) {
    return callback();
  } else {
    print('User ${messageContext.userId} is not admin');
    return ReactionNone();
  }
}
