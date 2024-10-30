import 'package:xmpp_stone/src/elements/messages/xmpp_0422/RecalledElement.dart';

import '../../../xmpp_stone.dart';

/// Inspired by this XEP-0422: https://xmpp.org/extensions/xep-0422.html

abstract class DeletedMessageInterface {
  DeletedMessageInterface addDeleteMessage(String fromUserId, String listMessageId);
  XmppElement? getDeletedMessage();
  bool isDeletedMessage();
}
