import 'package:xmpp_stone/src/elements/XmppAttribute.dart';
import 'package:xmpp_stone/src/elements/XmppElement.dart';

class ChatStateTypingElement extends XmppElement {
  static String elementName = 'typing';
  ChatStateTypingElement() {
    name = elementName;
  }

  ChatStateTypingElement.build() {
    name = elementName;
    addAttribute(
        XmppAttribute('xmlns', 'http://jabber.org/protocol/chatstates'));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == ChatStateTypingElement.elementName),
        orElse: () => null);
  }
}
