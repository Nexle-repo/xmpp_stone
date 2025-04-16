import 'package:xmpp_stone/src/elements/XmppElement.dart';

abstract class NoCopyInterface {
  NoCopyInterface addNoCopy();
  XmppElement? getNoCopy();
}
