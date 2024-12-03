import 'package:xmpp_stone/xmpp_stone.dart';

/// Inspired by this XEP-0333: https://xmpp.org/extensions/xep-0333.html

abstract class RequestMarkableInterface {
  RequestMarkableInterface addRequestMarkable();
  XmppElement? getRequestMarkable();
}
