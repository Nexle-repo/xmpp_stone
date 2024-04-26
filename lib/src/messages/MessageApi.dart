import 'package:xmpp_stone/src/data/Jid.dart';
import 'package:xmpp_stone/src/elements/encryption/EncryptElement.dart';
import 'package:xmpp_stone/src/elements/stanzas/MessageStanza.dart';
import 'package:xmpp_stone/src/messages/MessageParams.dart';

abstract class MessageApi {
  Future<MessageStanza> sendMessage(
    Jid to,
    String text,
    bool isCustom, {
    MessageParams additional,
  });

  Future<MessageStanza> sendSystemMessage(
    Jid to,
    String text, {
    MessageParams additional,
  });

  Future<MessageStanza> sendSecureMessage(
    Jid to,
    EncryptElement encryptElement, {
    MessageParams additional,
  });

  Future<MessageStanza> pinMessage(
    Jid to,
    String messageId,
    bool isPinned, {
    MessageParams additional,
  });

  Future<MessageStanza> reactMessage(
    Jid to,
    String messageId,
    String text,
    String reaction, {
    bool isClear = false,
    MessageParams additional,
  });

  Future<MessageStanza> editMessage(
    Jid to,
    String messageId,
    String text,
    String editContent, {
    MessageParams additional,
  });

  Future<MessageStanza> readMessage({
    required Jid to,
    required String userId,
    required String messageId,
    String text = '',
    MessageParams additional,
  });

  Future<MessageStanza> pinChat(
    Jid to,
    bool isPinned, {
    MessageParams additional,
  });

  Future<MessageStanza> quoteMessage(
      Jid to,
      String messageId,
      String body,
      String quoteText,
      String userId,
      String username,
      String? messageType,
      String? expts,
      {MessageParams additional});

  Future<MessageStanza> recallMessage(
    Jid jid,
    List<String> messageId,
    String userId, {
    MessageParams additional,
  });

  Future<MessageStanza> sendMUCInfoMessage(
    Jid to, {
    String? subject,
    String? coverUrl,
    MessageParams additional,
  });

  Future<MessageStanza> changeMemberRole(
    Jid to, {
    required String userJid,
    required String role,
    MessageParams additional,
  });
}
