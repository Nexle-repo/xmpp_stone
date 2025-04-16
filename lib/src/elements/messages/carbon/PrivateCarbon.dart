import 'package:xmpp_stone/xmpp_stone.dart';

import '../../XmppAttribute.dart';

class PrivateCarbonElement extends XmppElement {
  static String elementName = 'private';
  PrivateCarbonElement() {
    name = elementName;
  }

  PrivateCarbonElement.build() {
    name = elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:carbons:2'));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
            (child) => (child.name == PrivateCarbonElement.elementName),
        orElse: () => null);
  }

  static MessageStanza? parseForMessage(parent) {
    XmppElement? parentXmpp = parse(parent)!;
    if (parentXmpp != null) {
      return parentXmpp.children.firstWhere((child) => (child is MessageStanza),
          orElse: () => null) as MessageStanza;
    } else {
      return null;
    }
  }
}
