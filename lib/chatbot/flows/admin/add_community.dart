import 'package:chatterbox/chatterbox.dart';
import 'package:database/database.dart';
import 'package:jobstash_bot/chatbot/flows/admin/admin_base_flow.dart';
import 'package:jobstash_bot/chatbot/services/filters_repository.dart';
import 'package:telegram_api/shared_api.dart';

class AddCommunityFlow extends CommandFlow {
  AddCommunityFlow(this._repo, this._api);

  final TelegramBotApi _api;
  final FiltersRepository _repo;

  @override
  String get command => 'set_community';

  @override
  List<StepFactory> get steps => [
        () => _NewCommunityInitialStep(_repo, _api),
      ];
}

class _NewCommunityInitialStep extends AdminFlowStep {
  _NewCommunityInitialStep(this._repo, this._api);

  final TelegramBotApi _api;
  final FiltersRepository _repo;

  @override
  Future<Reaction> handleAdmin(MessageContext messageContext, [List<String>? args]) async {
    final firstArg = args?.firstOrNull;
    final communityId = firstArg != null ? int.tryParse(firstArg) : null;
    final communityNormalizedName = args?.last;

    if (communityId == null || communityNormalizedName == null) {
      return ReactionResponse(
          text: 'Please provide community id and community name. Example:\n`/set_community 1 community_name`',
          markdown: true);
    }

    try {
      final chatName = await _api.getChatName(communityId);
      if (chatName == null) {
        return ReactionResponse(
          text: 'Community with id $communityId not found. Please provide a valid community id.',
        );
      }

      await _repo.setUserFilterValue(communityId, UserFiltersDao.communityFilterKey, communityNormalizedName);

      return ReactionResponse(
        text: 'Success! Community filter `$communityNormalizedName` has been set for `$chatName`.',
        markdown: true,
      );
    } catch (error, stackTrace) {
      return ReactionResponse(
        text: '$error',
      );
    }
  }
}
