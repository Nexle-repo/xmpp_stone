import 'package:xmpp_stone/xmpp_stone.dart';

/// Inspired by this XEP-0422: https://xmpp.org/extensions/xep-0422.html

abstract class ApplyToInterface {
  ApplyToInterface addPinMessage(String messageId, bool isPinned);
  ApplyToInterface addQuoteMessage(String messageId, String userId, String username);
  XmppElement? getApplyTo();
  bool isPinMessage();
  bool isQuoteMessage();
}
