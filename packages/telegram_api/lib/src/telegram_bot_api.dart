import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

class TelegramBotApi {
  TelegramBotApi(String token) : _api = Bot(token).api;

  final RawAPI _api;

  Future<Message> forwardMessage(int toChatId, int fromChatId, int messageId) async {
    return await _api.forwardMessage(ID.create(toChatId), ID.create(fromChatId), messageId);
  }

  Future<bool> answerPreCheckoutQuery(String preCheckoutQueryId, bool success, {String? errorMessage}) =>
      _api.answerPreCheckoutQuery(preCheckoutQueryId, success, errorMessage: errorMessage);

  Future<Message> sendPhoto(dynamic chatId, String photoUrl, {String? caption, ReplyMarkup? replyMarkup}) async {
    final inputFile = InputFile.fromUrl(photoUrl);
    final message = await _api.sendPhoto(ID.create(chatId), inputFile, caption: caption, replyMarkup: replyMarkup);
    return message;
  }

  Future<Message> sendMessage(int userId, String text) {
    return _api.sendMessage(ID.create(userId), text);
  }

  Future<Message> sendHtmlMessage(int userId, String text) {
    return _api.sendMessage(ID.create(userId), text, parseMode: ParseMode.html);
  }

  Future<StickerSet> getStickerSet(String stickerSetId) {
    return _api.getStickerSet(stickerSetId);
  }
}
