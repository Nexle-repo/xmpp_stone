
import '../../../xmpp_stone.dart';

/// Inspired by this XEP-0422: https://xmpp.org/extensions/xep-0422.html

abstract class RecalledMessageInterface {
  RecalledMessageInterface addRecallMessage(String fromUserId, String listMessageId);
  XmppElement? getRecalledMessage();
  bool isRecalledMessage();
}
