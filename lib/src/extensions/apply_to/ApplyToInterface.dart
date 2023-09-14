import 'package:xmpp_stone/xmpp_stone.dart';

/// Inspired by this XEP-0422: https://xmpp.org/extensions/xep-0422.html

abstract class ApplyToInterface {
  ApplyToInterface changeMemberRole(String userJid, String role);

  ApplyToInterface addPinMessage(String messageId, bool isPinned);

  ApplyToInterface addReactMessage(
    String messageId,
    String reaction, {
    bool isClear = false,
  });

  ApplyToInterface addPinChat(String chatId, bool isPinned);

  ApplyToInterface addQuoteMessage(
      String messageId, String userId, String username);

  ApplyToInterface addMUCInfo({
    String? subjectChanged,
    String? coverUrlChanged,
  });

  XmppElement? getApplyTo();

  bool isPinMessage();

  bool isReactionMessage();

  bool isQuoteMessage();

  bool isMUCInfo();

  bool isChangeMemberRole();

  bool isPinChat();
}
