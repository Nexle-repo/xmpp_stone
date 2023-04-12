import '../../../xmpp_stone.dart';

abstract class SystemMessageInterface {
  SystemMessageInterface addSystemMessage();
  XmppElement? getSystemMessage();
  bool isSystemMessage();
}
