part of '../filters_setup_flow.dart';

final _filterId = 'tags';

class _TagsDisplayStep extends FlowStep {
  _TagsDisplayStep(this._repo);

  final FiltersRepository _repo;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final tags = await _repo.getUserFilterOptions(messageContext.userId, _filterId) as List<String>? ?? [];
    final editMessageId = messageContext.editMessageId;

    return ReactionResponse(
      editMessageId: editMessageId,
      text: """
${tags.isNotEmpty ? 'You *Current tags*: ${tags.join(', ')}' : ''}
      
*To update your tags*, please enter a comma-separated list of tags you are interested in
 
${tags.isEmpty ? '_For example: "typescript, nodejs, nft"_' : ''}
""",
      markdown: true,
      buttons: [
        InlineButton(
          title: 'Remove tags',
          nextStepUri: (_TagsRemoveStep).toStepUri([editMessageId.toString()]),
        ),
        InlineButton(
          title: '🔙 Back',
          nextStepUri: (FiltersFlowInitialStep).toStepUri([editMessageId.toString()]),
        ),
      ],
      afterReplyUri: (_TagsUpdateStep).toStepUri(),
    );
  }
}

class _TagsRemoveStep extends FlowStep {
  _TagsRemoveStep(this._repo);

  final FiltersRepository _repo;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    await _repo.setUserFilterValue(messageContext.userId, _filterId, null);

    return ReactionRedirect(stepUri: (FiltersFlowInitialStep).toStepUri([messageContext.editMessageId.toString()]));
  }
}

class _TagsUpdateStep extends FlowStep {
  _TagsUpdateStep(this._jobStashApi, this._repo);

  final JobStashApi _jobStashApi;
  final FiltersRepository _repo;

  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final userInput = messageContext.text?.split(',');

    if (userInput == null) {
      return ReactionResponse(
        text: 'Oops, something went wrong. Please try again.',
      );
    }

    try {
      final result = await _jobStashApi.matchTags(userInput);
      final data = result.data;

      if (!result.success || data == null) {
        return ReactionResponse(text: result.message ?? 'Oops, something went wrong. Please try again.');
      }

      final tags = data.recognizedTags;
      final unrecognizedInput = data.unrecognizedTags;

      await _repo.setUserFilterValue(messageContext.userId, _filterId, tags);

      final responseParts = <String>[];
      if (tags != null && tags.isNotEmpty) {
        responseParts.add('Your tags are set to: ${_taggify(tags)}');
      }
      if (unrecognizedInput != null && unrecognizedInput.isNotEmpty) {
        responseParts.add('We could not recognize: ${_taggify(unrecognizedInput)}');
      }

      if (responseParts.isEmpty) {
        return ReactionRedirect(stepUri: (_TagsTryAgainStep).toStepUri());
      }

      return ReactionComposed(responses: [
        ReactionResponse(text: responseParts.join('\n'), markdown: true),
        ReactionRedirect(stepUri: (FiltersFlowInitialStep).toStepUri()),
      ]);
    } catch (error, stacktrace) {
      logErrorToTelegramChannel('Failed update TagsFilter', error, stacktrace);
      return ReactionResponse(
        text: 'Oops, something went wrong. Please try again.',
      );
    }
  }

  String _taggify(List<String> tags) => tags.map((e) => '`${e.trim()}`').join(', ');
}

class _TagsTryAgainStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    return ReactionComposed(responses: [
      ReactionResponse(
        text: "Could not recognize your tags. Please to spell in different a way or use different tags.",
      ),
    ]);
  }
}
